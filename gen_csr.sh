#!/bin/bash

cname=$1

openssl req -newkey rsa:2048 -nodes -keyout ${cname}.key -out ${cname}.csr -subj "/C=PL/ST=Mazowieckie/L=Warszawa/O=SolidGroup/OU=IT/CN=$cname"
