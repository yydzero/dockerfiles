FROM yydzero/centos

ADD cmake-3.12.4-Linux-x86_64.tar.gz /
#RUN tar -xf /cmake-3.12.4-Linux-x86_64.tar.gz

# Change to user 'test'
USER test
WORKDIR /home/test

# clone gporca and dependencies
RUN git clone git://github.com/greenplum-db/gp-xerces.git
RUN git clone git://github.com/greenplum-db/gporca.git

WORKDIR gp-xerces
RUN mkdir build && cd build \
    && mkdir -p /home/test/sparrowdb && chown -R test /home/test/sparrowdb \
    && ../configure --prefix=/home/test/sparrowdb  \
    && make && make install

ADD ninja /usr/bin
RUN sudo chmod +x /usr/bin/ninja

WORKDIR /home/test/gporca
RUN /cmake-3.12.4-Linux-x86_64/bin/cmake -GNinja \
        -D XERCES_INCLUDE_DIR=/home/test/sparrowdb/include/  \
        -D XERCES_LIBRARY=/home/test/sparrowdb/lib/libxerces-c.so \
        -D CMAKE_INSTALL_PREFIX=/home/test/sparrowdb \
        -H. -Bbuild \
    && ninja install -C build 

RUN git clone git://github.com/greenplum-db/gpdb.git
WORKDIR /home/test/gpdb
RUN ./configure --prefix=/home/test/sparrowdb --enable-orca \
        --with-libedit-preferred --with-python --with-perl \
        --with-ldap --with-libxml \
    && make && make install

CMD bash
