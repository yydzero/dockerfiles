#!/bin/bash

# Start ssh daemon which is used by pgxc_ctl to manage cluster.
sudo /usr/sbin/sshd

# Setup needed environment in .bashrc and .bash_profile
echo 'PATH="/home/test/pgxl/bin:${PATH}"' >> /home/test/.bashrc
echo 'dataDirRoot=/home/test/DATA/pgxl/nodes' >> /home/test/.bashrc
echo 'USER=test' >> /home/test/.bashrc
echo 'export PATH dataDirRoot USER' >> /home/test/.bashrc

echo 'PATH="/home/test/pgxl/bin:${PATH}"' >> /home/test/.bash_profile
echo 'dataDirRoot=/home/test/DATA/pgxl/nodes' >> /home/test/.bash_profile
echo 'USER=test' >> /home/test/.bash_profile
echo 'export PATH dataDirRoot USER' >> /home/test/.bash_profile


source /home/test/.bashrc

pgxc_ctl prepare config empty
pgxc_ctl add gtm master gtm localhost 20001 $dataDirRoot/gtm
pgxc_ctl add coordinator master coord1 localhost 30001 30011 $dataDirRoot/coord_master.1 none none
pgxc_ctl add coordinator master coord2 localhost 30002 30012 $dataDirRoot/coord_master.2 none none
pgxc_ctl add datanode master dn1 localhost 40001 40011 $dataDirRoot/dn_master.1 none none none
pgxc_ctl add datanode master dn2 localhost 40002 40012 $dataDirRoot/dn_master.2 none none none
pgxc_ctl monitor all
