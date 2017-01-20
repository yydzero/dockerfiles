# Copyright 2016-2017 Pivotal Inc. All rights reserved.

FROM centos:latest
MAINTAINER vcheng@pivotal.io
RUN yum -y install \
        krb5-workstation \
        krb5-libs \
        krb5-devel \
        postgresql \
        openldap openldap-clients \
        wget 

CMD rm -f /etc/krb5.conf \
    && echo "TLS_REQCERT allow" >> /etc/openldap/ldap.conf \
    && cp /opt/kerberos/krb5.conf /etc/krb5.conf \
    && export KRB5CCNAME=DIR:/tmp/krb5_cc\
    && kinit -kt /opt/kerberos/krb5.keytab ${USER_NAME}@${REALM_NAME} \
    && psql -h gpdb -p 5432 -U ${USER_NAME} gpperfmon -c '\l' \
    && /bin/bash
