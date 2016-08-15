# File description

- ca-bundle.crt: bundled certification
- server.crt: server's certification, assume server's FQDN: ldapserver
- server.key: server's key without password protection. LDAP could not work with
server key with password protection.

# How to generate above files

Refer to [Create SSL Certifications](https://www.server-world.info/en/note?os=CentOS_7&p=ssl)

    [root@www ~]# cd /etc/pki/tls/certs 
    [root@www certs]# make server.key 
    umask 77 ; \
    /usr/bin/openssl genrsa -aes128 2048 > server.key
    Generating RSA private key, 2048 bit long modulus
    ...
    ...
    e is 65537 (0x10001)
    Enter pass phrase:# set passphrase
    Verifying - Enter pass phrase:# confirm
    
    # remove passphrase from private key
    [root@www certs]# openssl rsa -in server.key -out server.key 
    Enter pass phrase for server.key:# input passphrase
    writing RSA key

    [root@www certs]# make server.csr 
    umask 77 ; \
    /usr/bin/openssl req -utf8 -new -key server.key -out server.csr
    You are about to be asked to enter information that will be incorporated
    into your certificate request.
    What you are about to enter is what is called a Distinguished Name or a
    DN.
    There are quite a few fields but you can leave some blank
    For some fields there will be a default value,
    If you enter '.', the field will be left blank.
    -----
    Country Name (2 letter code) [XX]:JP# CN
    State or Province Name (full name) []:Hiroshima   # Beijing
    Locality Name (eg, city) [Default City]:Hiroshima #  Beijing
    Organization Name (eg, company) [Default Company Ltd]:GTS   # Pivotal
    Organizational Unit Name (eg, section) []:Server World   # Data
    Common Name (eg, your name or your server's hostname) []: ldapserver # server's FQDN
    Email Address []:xxx@srv.world# adamin@ldapserver.com
    Please enter the following 'extra' attributes
    to be sent with your certificate request
    A challenge password []:# Enter
    An optional company name []:# Enter

    [root@www certs]# openssl x509 -in server.csr -out server.crt -req -signkey server.key -days 3650
    Signature ok
    subject=/C=CN/ST=Beijing/L=Beijing/O=Pivotal/OU=Data/CN=ldapserver/emailAddress=yyao@pivotal.io
    Getting Private key
