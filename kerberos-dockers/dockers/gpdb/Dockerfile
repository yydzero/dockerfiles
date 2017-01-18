FROM gpccdocker/gpdb4311_gpperfmon
MAINTAINER vcheng@pivotal.io

ADD pg_hba.conf /gpdata/master/gpseg-1/pg_hba.conf
ADD entrypoint.sh /tmp/entrypoint.sh
EXPOSE 5432 22
CMD echo "127.0.0.1 $(cat ~/orig_hostname)" >> /etc/hosts \
        && rm -f /etc/krb5.conf \
        && cp /opt/kerberos/krb5.conf /etc/krb5.conf \
        && service sshd start \
        && su gpadmin -l -c "export USER_NAME=${USER_NAME}; export USER_PASSWORD=${USER_PASSWORD};export REALM_NAME=${REALM_NAME};/tmp/entrypoint.sh" \
        && /bin/bash

