# Base docker image of CentOS 7 for development

## Use this docker image

    $ docker pull yydzero/centos

    $ docker images ls

    $ docker run --rm -it c630057ab2c3

## Build docker image from Dockerfile

    $ docker build -t yydzero/centos -f Dockerfile .
    ...
    Successfully tagged yydzero/centos:latest

    $ docker login -u yydzero
    Password:
    Login Succeeded

    $ docker push yydzero/centos
