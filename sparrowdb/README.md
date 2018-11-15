# Dockerfile for PostgreSQL-XL

## How to use

    $ docker pull yydzero/gpdb

This docker file build greenplum binary for RHEL 7

## Build image from docker file

    $ curl https://cmake.org/files/v3.12/cmake-3.12.4-Linux-x86_64.tar.gz

    $ docker build -t yydzero/gpdb -f Dockerfile .

    $ docker login -u yydzero

    $ docker push yydzero/gpdb
