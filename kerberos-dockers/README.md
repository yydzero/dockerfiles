# How To Use

This dockers create a kdc server, a gpdb server that enabled kerberos login, and a client with psql and kerberos installed.

Notice:

* The script will using local machine's 5432 port, if local machine's 5432 port is occupied, it will fail to start the gpdb container.
* The script will test gpdb container using psql, so please make sure you have psql installed in your local machine.


To start with cached docker images

    $ ./run.sh

To re-build all the docker images

	$ ./run.sh -r

## Change pre-defined variables
run.sh has several predifined variables. They are mainly for kerberos setting and gpdb user create. You can change them to what you like.

* REALM_NAME 

	kerberos realm name
	
* DOMAIN_NAME
	
	kerberos domain name

* USER_NAME
	
	The gpdb user used to login through kerberos
	
* USER_PASSWORD

	The gpdb user's password, used for user creation.
	

## Using client container to run psql

After run.sh finished, three containers will be up, kdc/gpdb/client. Client container will test kerberos login and execute '\l' command through psql.

You can attach to client and play with it by yourself.

	$ docker attach client



## Using the kerberos server and set your local machine

During the run.sh running, it will print out "temp dir" path. It located at ~/tmp/.

You can find our krb5.conf and the keytab file in the path. If you have kerberos workstation installed in your machine, you can copy ther krb5.conf into /etc/ and start to use kdc container as kerberos service server.

To install kerberos workstation in centos:

	$ sudo yum install krb5-workstation krb5-libs