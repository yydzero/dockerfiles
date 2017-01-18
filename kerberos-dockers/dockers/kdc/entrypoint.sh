#!/bin/bash -eu

# Add kerberos principals.
kadmin.local -q "addprinc -pw ${USER_PASSWORD} ${USER_NAME}@${REALM_NAME}"
kadmin.local -q "addprinc -pw ${USER_PASSWORD} postgres/gpdb@${REALM_NAME}"
# Export keytab.
kadmin.local -q "xst -k /etc/docker-kdc/krb5.keytab -norandkey ${USER_NAME}@${REALM_NAME} postgres/gpdb@${REALM_NAME}"


# KDC daemon startup.
krb5kdc -p 88
exec /bin/bash
