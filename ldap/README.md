

systemd does not run inside your container unless you tell it to. Typically you
run one process per container whenever possible.

    $ docker build -t yydzero/ldap -f Dockerfile .
    $ docker run --rm -it d519160e8449
