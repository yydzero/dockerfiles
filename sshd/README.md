# How to run SSHD in docker


This directory contains some docker file to demo different ways to 
run SSHD in OS CentOS 7.5.

## Use supervisor

* Dockerfile
RUN easy_install supervisor \
    && mkdir -p /etc/supervisor/ \
    && cp /tmp/supervisord.conf /etc/supervisor/supervisord.conf
CMD  /usr/bin/supervisord

* supervisord.conf
[supervisord]
nodaemon=true

[program:sshd]
command=/usr/sbin/sshd -D

## use init.d ssh service

Please try install below package:

openssh-server-sysvinit

It will provide the /etc/init.d/ssh service.  By default only the systemd
service is installed but systemd can not be used in docker.

