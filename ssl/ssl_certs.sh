#!/bin/bash

shopt -s extglob
DIR=$( dirname $0 )

usage() {
    cat <<EOF
usage: $0 option

OPTIONS:
   help       Show this message
   clean      Clean up
   generate   Generate SSL certificates for Sensu
EOF
}

clean() {
    rm -rf client server ssl.json
    if [ -d "sensu_ca" ]; then
        cd sensu_ca
        rm -rf !(openssl.cnf)
    fi
}

generate() {
    # Generates the following files
    #
    # ssl/server/cacert.pem
    # ssl/server/key.pem
    # ssl/server/cert.pem
    # ssl/client/key.pem
    # ssl/client/cert.pem
    OLDPWD=$PWD

    # Prepare CA
    mkdir -p $DIR/client $DIR/server $DIR/sensu_ca/private $DIR/sensu_ca/certs
    touch $DIR/sensu_ca/index.txt
    echo 01 > $DIR/sensu_ca/serial

    # Generate CA Certificate.
    # Usage details below.
    #
    # | TYPE      | HOST     | REPOFILE                      | HOSTFILE                       | VALUE
    # +-----------+----------+-------------------------------+--------------------------------+---------------
    # | mapping   | rabbitmq | ssl/sensu_ca/cacert.pem       | /etc/rabbitmq/ssl/cacert.pem   |
    # | reference | rabbitmq | rabbitmq/conf/rabbitmq.config | /etc/rabbitmq/rabbitmq.config  | {ssl_options, [{cacertfile,"/etc/rabbitmq/ssl/cacert.pem"}
    #
    cd $DIR/sensu_ca
    openssl req -x509 -config openssl.cnf -newkey rsa:2048 -days 1825 -out cacert.pem -outform PEM -subj /CN=SensuCA/ -nodes

    # Create Server CSR
    cd ../server
    openssl genrsa -out key.pem 2048
    openssl req -new -key key.pem -out req.pem -outform PEM -subj /CN=sensu/O=server/ -nodes

    # Generate Server Certificate.
    # Usage details below.
    # 
    # | TYPE      | HOST     | REPOFILE                       | HOSTFILE                      | VALUE
    # +-----------+----------+-------------------+------------+-------------------------------+---------------
    # | mapping   | rabbitmq | ssl/server/cert.pem            | /etc/rabbitmq/ssl/cert.pem    | 
    # | reference | rabbitmq | rabbitmq/conf/rabbitmq.config  | /etc/rabbitmq/rabbitmq.config | {certfile,"/etc/rabbitmq/ssl/cert.pem"},
    # | mapping   | sensu    | ssl/server/cert.pem            | /etc/sensu/ssl/cert.pem       | 
    # | reference | sensu    | sensu/conf/config.json         | /etc/sensu/config.json        | "cert_chain_file": "/etc/sensu/ssl/cert.pem"
    #
    cd ../sensu_ca
    openssl ca -config openssl.cnf -in ../server/req.pem -out ../server/cert.pem -notext -batch -extensions server_ca_extensions

    # delete server CSR
    rm ../server/req.pem

    # generate client CSR
    cd ../client
    openssl genrsa -out key.pem 2048
    openssl req -new -key key.pem -out req.pem -outform PEM -subj /CN=sensu/O=client/ -nodes
    # generate client certificate
    cd ../sensu_ca
    openssl ca -config openssl.cnf -in ../client/req.pem -out ../client/cert.pem -notext -batch -extensions client_ca_extensions
    # delete client CSR
    cd ../client
    rm req.pem
    cd $OLDPWD
}

if [ "$1" = "generate" ]; then
    echo "Generating SSL certificates for Sensu ..."
    generate
elif [ "$1" = "clean" ]; then
    echo "Cleaning up ..."
    clean
else
    usage
fi
