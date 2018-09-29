FROM yydzero/centos

# yydzero/centos image contains user 'test' with ssh configured.

USER gpadmin
WORKDIR /home/test

# clone and compile postgres-xl 10
RUN git clone git://git.postgresql.org/git/postgres-xl.git
WORKDIR postgres-xl
RUN git checkout XL_10_STABLE
RUN ./configure --enable-debug --enable-cassert --prefix=/home/test/pgxl
RUN make && make install
RUN make -C contrib && make -C contrib install

# init cluster: 1 GTM, 2 coordinator master, 2 datanode master
ENV PATH="/home/test/pgxl:${PATH}"
RUN pgxc_ctl prepare config empty
RUN pgxc_ctl add gtm master gtm localhost 20001 $dataDirRoot/gtm
RUN pgxc_ctl add coordinator master coord1 localhost 30001 30011 $dataDirRoot/coord_master.1 none none
RUN pgxc_ctl add coordinator master coord2 localhost 30002 30012 $dataDirRoot/coord_master.2 none none
RUN pgxc_ctl add datanode master dn1 localhost 40001 40011 $dataDirRoot/dn_master.1 none none none
RUN pgxc_ctl add datanode master dn2 localhost 40002 40012 $dataDirRoot/dn_master.2 none none none
RUN monitor all
