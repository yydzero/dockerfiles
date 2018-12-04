#!/bin/bash

# start ssh daemon which is used even on single node cluser
sudo /usr/sbin/sshd

# make demo cluster
cd /home/test/gpdb/gpAux/gpdemo
source /home/test/sparrowdb/greenplum_path.sh 
make
