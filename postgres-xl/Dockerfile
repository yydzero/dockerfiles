FROM yydzero/centos

# Add pgxl cluster setup script
ADD setup_pgxl.sh /setup_pgxl.sh

# Change to user 'test'
USER test
WORKDIR /home/test

# clone and compile postgres-xl 10
RUN git clone git://git.postgresql.org/git/postgres-xl.git

WORKDIR postgres-xl
RUN git checkout XL_10_STABLE

RUN ./configure --enable-debug --enable-cassert --prefix=/home/test/pgxl
RUN make && make install
RUN make -C contrib && make -C contrib install

# init postgres-xl cluster: 1 GTM, 2 coordinator master, 2 datanode master
RUN /setup_pgxl.sh

EXPOSE 30001 30002

CMD sudo /usr/sbin/sshd && bash
