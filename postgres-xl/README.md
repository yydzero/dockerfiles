# Dockerfile for PostgreSQL-XL

## How to use

    $ docker pull yydzero/pgxl

timestamp: 2018/09/29

This docker file build postgres-xl release 10 and setup a local
cluster with: 1 GTM, 2 coordinator master and 2 datanode master.

Once downloaded, try with one coordinator:

    $ psql -p 30001 postgres
    testdb=# SELECT * FROM pgxc_node;

## Build container from image

    $ docker build -t yydzero/pgxl -f Dockerfile .

    $ docker login -u yydzero

    $ docker push yydzero/pgxl