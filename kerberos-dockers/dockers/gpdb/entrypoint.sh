#!/bin/bash
export LOGNAME=gpadmin
export USER=gpadmin
export MASTER_DATA_DIRECTORY=/gpdata/master/gpseg-1
export KRB5CCNAME=DIR:/tmp/krb5_cc
source /usr/local/greenplum-db/greenplum_path.sh
export LD_LIBRARY_PATH=/lib64:$LD_LIBRARY_PATH
cp /opt/kerberos/krb5.keytab /home/gpadmin/krb5.keytab
kinit -kt /home/gpadmin/krb5.keytab ${USER_NAME}@${REALM_NAME}

echo -e "krb_srvname = 'postgres'\ngp_enable_gpperfmon=on\nkrb_server_keyfile = '/home/gpadmin/krb5.keytab'" >> /gpdata/master/gpseg-1/postgresql.conf

gpstart -a
psql -d gpadmin -t -c "create role ${USER_NAME} with login password '${USER_PASSWORD}'; GRANT gpcc_operator TO ${USER_NAME}"
