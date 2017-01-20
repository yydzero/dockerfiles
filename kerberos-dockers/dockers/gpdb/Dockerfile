FROM gpccdocker/gpdb4311_gpperfmon
MAINTAINER vcheng@pivotal.io
RUN yum -y install \
    postgresql \
    openldap \
    openldap-clients
ADD certs/ca-bundle.crt /etc/openldap/certs/ca-bundle.crt
ADD pg_hba.conf /gpdata/master/gpseg-1/pg_hba.conf
ADD entrypoint.sh /tmp/entrypoint.sh
EXPOSE 5432 22

       
CMD echo "127.0.0.1 $(cat ~/orig_hostname)" >> /etc/hosts \
        && echo -e "TLS_REQCERT allow\nTLS_CACERTDIR /etc/openldap/certs\nTLS_CACERT /etc/openldap/certs/ca-bundle.crt" >> /etc/openldap/ldap.conf \
        && cd /etc/openldap/certs/ && openssl x509 -noout -hash -in ca-bundle.crt && ln -s ca-bundle.crt ca-bundle.crt.0 \
        && chown -R gpadmin:gpadmin /gpdata/master/gpseg-1/pg_hba.conf \
        && rm -f /etc/krb5.conf \
        && cp /opt/kerberos/krb5.conf /etc/krb5.conf \
        && service sshd start \
        && su gpadmin -l -c "export LDAP_USER_NAME=${LDAP_USER_NAME}; export USER_NAME=${USER_NAME}; export USER_PASSWORD=${USER_PASSWORD};export REALM_NAME=${REALM_NAME};/tmp/entrypoint.sh" \
        && /bin/bash
