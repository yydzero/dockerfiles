#!/bin/bash -eu

# Copyright 2016-2017 Pivotal Inc. All rights reserved.

# Author: vcheng@pivotal.io

REALM_NAME="KRB.GREENPLUM.COM"
DOMAIN_NAME="kerberos-gpdb"
USER_NAME="kerberos_user"
LDAP_USER_NAME="ldap_user"
USER_PASSWORD="changeme"

progname=$0
function usage () {
    cat <<EOF
Usage: $progname [-r] [-s]
    -r: rebuild images and run
    -s: shut down and rm all opened services docker
EOF
    exit 0
}
while getopts "rs" opt; do
    case $opt in
    r) REBUILD_DOCKER_IMAGES="true";;
    s) CLOSE_SERVICES="true";;
    h) usage;;
    esac
done

if [[ "$OSTYPE" == "darwin"* ]]; then
        DOCKER=docker
else
        DOCKER='docker'
fi


function log() {
        printf "kerberos-gpdb: %s\n" "$*" >&2
}


function cleanup_containers() {
        log "clean up running containers"
        running=`$DOCKER ps --all | grep 'kerberos-gpdb' | awk '{print $1}'`
        if [[ "$running" != "" ]]; then
                echo $running | xargs $DOCKER stop
                echo $running | xargs $DOCKER rm
        fi
}

if [[ "${CLOSE_SERVICES:-}" != "" ]]; then
    echo "close all open service dockers..."
    cleanup_containers
    echo "done"
    echo "clean $HOME/krbtmp/"
    rm -rf $HOME/krbtmp
    exit 0
fi

BASE_DIR=$(dirname "$0")/
UUID="$(uuidgen)"
export TEST_DIR="$HOME/krbtmp/$UUID"
mkdir -p -- "$TEST_DIR"
cp -R "$BASE_DIR" "$TEST_DIR"
echo "WARNING: This script will start gpdb docker on your 5432 port, please make sure your local gpdb is stopped or not running on 5432."
DOCKER_DIR="$TEST_DIR/dockers"
echo "Temp dir is $TEST_DIR"
cp -R "$DOCKER_DIR/ldap/certs" "$DOCKER_DIR/gpdb/"

which psql > /dev/null 2>&1
	if [ $? != 0 ] ; then
		echo -e "psql not fount in your path, please add/install it first\n"
		exit 1
	fi


function cleanup() {
        set +e
        cleanup_containers
       # log "Clean up build directory ${TEST_DIR}"
       # rm -rf -- "${TEST_DIR:?}"
}

function build_image() {
        comp="$1"
        name="$2"
        func="$3"
        img="kerberos-gpdb-${name}"
        image="$($DOCKER images --quiet ${img})"
        if [[ "$func" != "" ]]; then
            (${func})
        fi

        if [[ "${REBUILD_DOCKER_IMAGES:-}" == "" && "$image" != "" ]]; then
                log "Reuse cached docker image ${img} ${image}"
        else
                log "Build docker image ${img}"
                $DOCKER build \
                        --rm \
                        --tag=${img} \
                        "${comp}"
        fi
}

# Caveat: Quote characters in USER_PASSWORD may cause Severe Pain.
#         Don't do that.
#         This only has to handle Docker tests, not quite the Real World,
#         so we can get away with this restriction.
#
function run_image() {
        comp="$1"
        name="$2"
        options="$3"
        img="kerberos-gpdb-${name}"
        log "Run docker image ${img}"
        options="${options} \
                --hostname=${comp} \
                --name=${comp} \
                --env USER_NAME=${USER_NAME} \
                --env LDAP_USER_NAME=${LDAP_USER_NAME} \
                --env USER_PASSWORD=${USER_PASSWORD} \
                --env REALM_NAME=${REALM_NAME} \
                --env DOMAIN_NAME=${DOMAIN_NAME}"
        $DOCKER run -P ${options} ${img}
}

function map_ports() {
        comp="$1"
        name="kerberos-gpdb-$2"
        port="$3"
        COMP="$(printf "%s\n" "$comp" | tr '[:lower:]' '[:upper:]')"
        if [[ "${OSTYPE}" == "darwin"* ]]; then
                b2d_ip=$(docker-machine ip default)
                export ${COMP}_PORT_${port}_TCP_ADDR=${b2d_ip}
        else
                export ${COMP}_PORT_${port}_TCP_ADDR=127.0.0.1
        fi
        export ${COMP}_PORT_${port}_TCP_PORT=$($DOCKER port ${comp} ${port} | cut -f2 -d ':')
}

function wait_until_available() {
        comp="$1"
        addr="$2"
        port="$3"

        let i=1
        echo "$1: $addr:$port"
        if [[ "$1" == "gpcc" ]]; then
            while ! [[ $(curl -is "http://$addr:$port") == *"html"* ]]; do
                sleep 5
                let i++
                if (( i > 10 )); then
                    echo "Timed out waiting for ${comp} to start at ${addr}:${port}"
                    exit 1
                fi
            done
        else
            while ! echo exit | nc -vn $addr $port >/dev/null; do
                    echo "Waiting for $comp to start"
                    sleep 1
                    let i++
                    if (( i > 10 )); then
                           echo "Timed out waiting for ${comp} to start at ${addr}:${port}"
                           exit 1
                    fi
            done
        fi
}

# Cleanup
#trap 'cleanup' INT TERM EXIT
cleanup_containers

env_suffix=$(/bin/echo "${REALM_NAME}" | shasum | cut -f1 -d ' ')
#$DOCKER network create gpcc-network-$UUID
# KDC
cat "$DOCKER_DIR/kdc/krb5.conf.template" \
        | sed -e "s/KDC_ADDRESS/0.0.0.0:88/g" \
        | sed -e "s/DOMAIN_NAME/${DOMAIN_NAME}/g" \
        | sed -e "s/REALM_NAME/${REALM_NAME}/g" \
        > "$DOCKER_DIR/kdc/krb5.conf"

cat "$DOCKER_DIR/ldap/ldif/user.ldif.template" \
                | sed -e "s/LDAP_USER_NAME/${LDAP_USER_NAME}/g" \
                > "$DOCKER_DIR/ldap/ldif/user.ldif"

build_image "$DOCKER_DIR/kdc" "kdc-${env_suffix}" "" 
run_image "kdc" "kdc-${env_suffix}" "-dit -p 88:88"
map_ports "kdc" "kdc-${env_suffix}" 88 
wait_until_available "kdc" $KDC_PORT_88_TCP_ADDR $KDC_PORT_88_TCP_PORT

build_image "$DOCKER_DIR/ldap" "ldap-${env_suffix}" "" 
run_image "ldap" "ldap-${env_suffix}" "-dit -p 389:389 -p 636:636 --hostname=ldap"

function keytab_from_kdc() {
        $DOCKER cp kdc:/etc/docker-kdc/krb5.keytab "$TEST_DIR"
        chmod 777 $TEST_DIR/krb5.keytab
}

DOCKER_KDC_OPTS="--link=kdc:kdc \
            --link=ldap:myldap.com \
            --env KDC_PORT_88_TCP_ADDR=${KDC_PORT_88_TCP_ADDR} \
            --env KDC_PORT_88_TCP_PORT=${KDC_PORT_88_TCP_PORT}"
KEYTAB_FUNCTION='keytab_from_kdc'

cat "$DOCKER_DIR/kdc/krb5.conf.template" \
                | sed -e "s/KDC_ADDRESS/kdc:88/g" \
                | sed -e "s/DOMAIN_NAME/${DOMAIN_NAME}/g" \
                | sed -e "s/REALM_NAME/${REALM_NAME}/g" \
                > "$TEST_DIR/krb5.conf"

cat "$DOCKER_DIR/gpdb/pg_hba.conf.template" \
                | sed -e "s/REALM_NAME/${REALM_NAME}/g" \
                | sed -e "s/LDAP_USER_NAME/${LDAP_USER_NAME}/g" \
                | sed -e "s/USER_NAME/${USER_NAME}/g" \
                > "$DOCKER_DIR/gpdb/pg_hba.conf"

# GPDB service
log "Build gpdb on host"

build_image "$DOCKER_DIR/gpdb" "gpdb-${env_suffix}" "$KEYTAB_FUNCTION" 2>&1
run_image "gpdb" \
        "gpdb-${env_suffix}" \
        "-dit -p 5432:5432 \
        $DOCKER_KDC_OPTS \
        --volume $TEST_DIR:/opt/kerberos" >/dev/null
map_ports "gpdb" "gpdb-${env_suffix}" 5432
#wait_until_available "gpdb" $GPDB_PORT_5432_TCP_ADDR $GPDB_PORT_5432_TCP_PORT
count=1
until psql -h 0.0.0.0 -p $GPDB_PORT_5432_TCP_PORT -U gpadmin gpperfmon -c '\l' >/dev/null; do
    if [[ $count > 5 ]]; then
        echo "FAIL to start gpdb"
        exit
    fi
    count=`expr $count + 1`
    >&2 echo "GPDB is unavailable - sleeping"
    sleep 10
done

>&2 echo "GPDB is up"

# GSSAPI client
if [[ "$OSTYPE" != "darwin"* ]]; then
    build_image "$DOCKER_DIR/client" "client" "$KEYTAB_FUNCTION" 2>&1
    run_image "client" \
        "client" \
        "$DOCKER_KDC_OPTS \
        -dit \
        --link=gpdb:gpdb \
        --volume $TEST_DIR:/opt/kerberos" >/dev/null

    $DOCKER logs client 2>&1
fi
