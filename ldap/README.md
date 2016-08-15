# How to use this contaier

## Build container from image

    $ docker build -t yydzero/ldap -f Dockerfile .

## Start container with pre-defined name

Start container with specified hostname 'ldapserver', server name in server 
certificate is 'ldapserver', so we must use it as hostname, otherwise TLS will
report: "TLS: hostname does not match CN in peer certificate".

    $ docker run --rm -it -h ldapserver d519160e8449

## Start slapd (LDAP Server Daemon)

Start slapd:

    Run below command after start container:
    # /usr/sbin/slapd -u ldap -h "ldap:/// ldapi:///" [-d 1]

## Test LDAP server works

TLS works:

    $ ldapsearch -x -b 'dc=pivotal,dc=io' '(objectclass=*)' -ZZ

Search works:

    $ ldapsearch -x -b 'dc=pivotal,dc=io' -D 'cn=admin,dc=pivotal,dc=io' '(uid=tlsuser)' -ZZ -LLL -w changeme

## Test LDAP works from other host

Configure LDAP client:

    $ yum install -y openldap openldap-clients
    $ echo "TLS_REQCERT allow" >> /etc/openldap/ldap.conf

Test without SSL:

    $ ldapsearch -x -b 'dc=pivotal,dc=io' -D 'cn=admin,dc=pivotal,dc=io' '(uid=tlsuser)' -LLL -w changeme -H ldap://172.17.0.2 

Test with SSL:

    $ ldapsearch -x -b 'dc=pivotal,dc=io' -D 'cn=admin,dc=pivotal,dc=io' '(uid=tlsuser)' -LLL -w changeme -H ldap://172.17.0.2 -ZZZ

# OpenLDAP security

If you want to do SSL or TLS, you should know that the default behaviour is for
ldap clients to verify certificates, and give misleading bind errors if they
can't validate them. This means:

* if you're using self-signed certificates, add `TLS_REQCERT allow` to /etc/openldap/ldap.conf on your clients, which means allow certificates the clients can't validate
* if you're using CA-signed certificates, and want to verify them, add your CA PEM certificate to a directory of your choice (e.g. /etc/openldap/certs, or /etc/pki/tls/certs, for instance), and point to it using proper instructions.

# Other info

OpenLDAP 2.4 on RHEL7 is built against Mozilla NSS. Refer to slapd-config(5) for
more information:

    olcTLSCertificateFile: <filename>

    Specifies the file that contains the slapd server certificate.

    When using Mozilla NSS, if using a cert/key database (speicified with
    olcTLSCACertificatePath), olcTLSCertificateFile specifies the name of the
    certificate to use:
        
    olcTLSCertificateFile: Server-Cert

    If using a token other than the internal built in token, specify the token
    name first, followed by a colon:

    olcTLSCertificateFile: my hardware device:Server-Cert

    Use certutil -L to list the certificates by name:

    certutil -d /path/to/certdbdir -L


systemd does not run inside your container unless you tell it to. Typically you
run one process per container whenever possible.

Display certification content:

    $ openssl x509 -in servercrt.pem -text -noout
