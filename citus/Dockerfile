FROM centos:6.6

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
                      openssl-devel     \
                      openssl-libs      \
                      openssh-server    \
                      perl-CPAN         \
                      perl-devel        \
                      perl-ExtUtils-Embed   \
                      psmisc            \
                      python-devel      \
                      readline-devel    \
                      vim               \
                      zlib-devel

RUN useradd -ms /bin/bash -d /home/gpadmin gpadmin \
    && echo '%gpadmin ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers \
    && echo "gpadmin:changeme" | chpasswd  \
    && yum -y install sudo


WORKDIR /home/gpadmin/workspace

ADD Dockerfile Dockerfil
ADD postgresql postgresql/
ADD citus citus/

RUN chown -R gpadmin /home/gpadmin/workspace

USER gpadmin

# compile PostgreSQL & Citus
WORKDIR postgresql 

RUN ./configure --enable-cassert --enable-debug \
    && time make -j4    \
    && sudo make install

ENV PATH /usr/local/pgsql/bin:$PATH

WORKDIR /home/gpadmin/workspace/citus
RUN ./configure \
    && make -j4 \
    && sudo make install

RUN mkdir -p /home/gpadmin/cdb \
    && initdb -D /home/gpadmin/cdb \
    && echo "shared_preload_libraries = 'citus'" >> /home/gpadmin/cdb/postgresql.conf \
    && sed -i -e "s/^#listen_addresses = 'localhost'.*$/listen_addresses = '*'/g" /home/gpadmin/cdb/postgresql.conf \
    && echo 'host  all  all  10.0.0.0/8 trust' >> /home/gpadmin/cdb/pg_hba.conf \
    && pg_ctl -D /home/gpadmin/cdb -l logfile -w start \
    && psql template1 -c "CREATE EXTENSION citus;" \
    && createdb test \
    && psql test -c "SELECT VERSION()" \
    && pg_ctl -D /home/gpadmin/cdb -w stop
