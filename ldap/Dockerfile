FROM centos:7

RUN yum -y update \
    && yum -y groupinstall "Development tools" \
    && yum -y install epel-release      \
    && yum -y install apr-devel         \
                      bzip2-devel       \
                      ccache            \
                      cmake             \
                      curl-devel        \
                      htop              \
                      iproute           \
                      libevent-devel    \
                      libffi-devel      \
                      libxml2-devel     \
                      libyaml           \
                      libyaml-devel     \
                      mc                \
                      net-tools         \
                      openssl           \
                      openssl-devel     \
                      openssl-libs      \
                      openssl-perl      \
                      openssh-server    \
                      perl-CPAN         \
                      perl-devel        \
                      perl-ExtUtils-Embed   \
                      psmisc            \
                      python-devel      \
                      readline-devel    \
                      vim               \
                      zlib-devel        \
                      openldap openldap-servers openldap-clients

ADD ldif /ldif
ADD certs /certs

# 1. Start slapd daemon: slapd -u ldap -h "ldap:/// ldapi:///"
#
# 2. minimum slapd server configuration: olcRootPW, olcSuffix, olcRootDN
#   after these instructions, the 'olcDatabase={2}hdb,cn=config' database
#   will store subtree rooted from dc=pivotal,dc=io
#   root password is changeme.
#   refer to config.ldif for more information.
#
# 3. Add cosine and inetorgperson schema, in order to use uid attribute.
#
# 4. Load ldif data
RUN chown -R ldap:ldap /var/lib/ldap /var/run/openldap \
    && /usr/sbin/slapd -u ldap -h "ldap:/// ldapi:///" \
    && ldapmodify -Q -Y EXTERNAL -H ldapi:/// -f /ldif/config.ldif \
    && ldapadd -Q -Y EXTERNAL -H ldapi:/// -D "cn=config" -f /etc/openldap/schema/cosine.ldif \
    && ldapadd -Q -Y EXTERNAL -H ldapi:/// -D "cn=config" -f /etc/openldap/schema/inetorgperson.ldif \
    && ldapadd -vvv -x -D "cn=admin,dc=pivotal,dc=io" -w changeme -f /ldif/group.ldif \
    && ldapadd -vvv -x -D "cn=admin,dc=pivotal,dc=io" -w changeme -f /ldif/user.ldif \
    && ldappasswd -S -x -D "cn=admin,dc=pivotal,dc=io" -w changeme uid=plainuser,dc=pivotal,dc=io -s changeme \
    && ldappasswd -S -x -D "cn=admin,dc=pivotal,dc=io" -w changeme uid=tlsuser,dc=pivotal,dc=io -s changeme \
    && ldappasswd -S -x -D "cn=admin,dc=pivotal,dc=io" -w changeme uid=ldapsuser,dc=pivotal,dc=io -s changeme \
    && ldapsearch -x -b 'dc=pivotal,dc=io' '(objectclass=*)' \
    && ldapsearch -x -h localhost -D "uid=plainuser,dc=pivotal,dc=io" -w changeme -b "dc=pivotal,dc=io" cn 

# Run below command after start container:
# /usr/sbin/slapd -u ldap -h "ldap:/// ldapi:///" -d 1
