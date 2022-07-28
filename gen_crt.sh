#!/bin/bash

cname=$1
ca_name="${2:-ca-sg}"

openssl req -newkey rsa:2048 -nodes -keyout ${cname}.key -out ${cname}.csr -subj "/C=PL/ST=Mazowieckie/L=Warszawa/O=SolidGroup/OU=IT/CN=$cname"
openssl req -x509 -nodes -key ${cname}.key -in ${cname}.csr -sha256 -days 3650 -out ${cname}.crt -subj "/C=PL/ST=Mazowieckie/L=Warszawa/O=SolidGroup/OU=IT/CN=$cname"
openssl x509 -req -in ${cname}.csr -CA ${ca_name}.pem -CAkey ${ca_name}.key -CAcreateserial -out ${cname}.crt -days 1825 -sha256 -extfile gen_crt_dns_alt_names.ext
