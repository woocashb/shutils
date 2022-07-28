#!/bin/bash

ca_name=$1

openssl req -newkey rsa:2048 -nodes -keyout ${ca_name}.key -out ${ca_name}.csr -subj "/C=PL/ST=Mazowieckie/L=Warszawa/O=SolidGroup/OU=IT/CN=$ca_name"
openssl req -x509 -nodes -key ${ca_name}.key -in ${ca_name}.csr -sha256 -days 3650 -out ${ca_name}.pem
