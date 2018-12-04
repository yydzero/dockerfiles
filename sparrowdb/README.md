# Dockerfile for PostgreSQL-XL

## How to use

### download and run images

    $ docker pull yydzero/spdb

    This docker image contains already built spdb

    $ docker run -h spdb -it <imageId>

### init cluster

    $ cd /home/test/gpdb/gpAux/gpdemo
    $ source /home/test/sparrowdb/greenplum_path.sh
    $ make

### try it 

    $ source gpdemo-env.sh
    $ psql postgres

## Build image from docker file

    $ curl https://cmake.org/files/v3.12/cmake-3.12.4-Linux-x86_64.tar.gz

    $ docker build -t yydzero/spdb -f Dockerfile .

    $ docker login -u yydzero

    $ docker push yydzero/spdb
