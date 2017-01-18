FROM centos:6
ADD krb5.conf /etc/krb5.conf

RUN yum -y install krb5-server krb5-libs krb5-workstation 
RUN mkdir -p /etc/docker-kdc
RUN kdb5_util -P changeme create
ADD entrypoint.sh /etc/docker-kdc/entrypoint.sh

EXPOSE	88
ENTRYPOINT /etc/docker-kdc/entrypoint.sh
