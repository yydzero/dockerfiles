FROM yydzero/centos

# Install dependencies. newer gcc is needed,
# as the default gcc on RHEL7 will encounter compiler
# issue: https://github.com/greenplum-db/gpdb/issues/6247
RUN yum clean all -y \
    && yum install -y centos-release-scl-rh \
                      openldap-devel wget \
    && yum install -y --setopt=tsflags=nodocs devtoolset-7 \
    && rpm -V devtoolset-7

RUN wget https://bootstrap.pypa.io/get-pip.py &&  \
    python get-pip.py && \
    pip install psutil lockfile paramiko setuptools epydoc

# Add build tools to build database
ADD cmake-3.12.4-Linux-x86_64.tar.gz /
ADD ninja /usr/bin
ADD initsp.sh /initsp.sh

RUN chmod +x /usr/bin/ninja
RUN chmod +x /initsp.sh

# Change to user 'test'
USER test
WORKDIR /home/test

# Use devtoolset 7 to build database
RUN echo 'source /opt/rh/devtoolset-7/enable' >> /home/test/.bash_profile
RUN echo 'source /opt/rh/devtoolset-7/enable' >> /home/test/.bashrc

ENV BASH_ENV=/opt/rh/devtoolset-7/enable \
    ENV=/opt/rh/devtoolset-7/enable \
    PROMPT_COMMAND=". /opt/rh/devtoolset-7/enable"

# clone gporca and dependencies
RUN git clone git://github.com/greenplum-db/gp-xerces.git
RUN git clone git://github.com/greenplum-db/gporca.git
RUN git clone git://github.com/greenplum-db/gpdb.git

WORKDIR gp-xerces
RUN mkdir build && cd build \
    && mkdir -p /home/test/sparrowdb && chown -R test /home/test/sparrowdb \
    && ../configure --prefix=/home/test/sparrowdb  \
    && make && make install

WORKDIR /home/test/gporca
RUN /cmake-3.12.4-Linux-x86_64/bin/cmake -GNinja \
        -D XERCES_INCLUDE_DIR=/home/test/sparrowdb/include/  \
        -D XERCES_LIBRARY=/home/test/sparrowdb/lib/libxerces-c.so \
        -D CMAKE_INSTALL_PREFIX=/home/test/sparrowdb \
        -H. -Bbuild \
    && ninja install -C build 

WORKDIR /home/test/gpdb
RUN . /opt/rh/devtoolset-7/enable \
    && LD_LIBRARY_PATH=/home/test/sparrowdb/lib \
    ./configure --prefix=/home/test/sparrowdb \
        --with-python --with-perl --with-ldap --with-libxml \
        --with-includes=/home/test/sparrowdb/include \
        --with-libraries=/home/test/sparrowdb/lib \
    && make && make install

# Init database cluster
# RUN /initsp.sh
# EXPOSE 15432

CMD sudo /usr/sbin/sshd && bash
