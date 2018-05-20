#!/usr/bin/bash

IFACE=$1
IPADDR=$2
HOSTNAME=$3
PREFIX=$4
GATEWAY=$5
DNS=$6

SCRIPT=$(basename $0)
SCRIPT_WD=$(dirname $0)

CFG_TEMPLATE=${SCRIPT_WD}/ifcfg

NETCFG_D=/etc/sysconfig/network-scripts
NETCFG_F=${NETCFG_D}/ifcfg-${IFACE}

function usage(){
printf "USAGE: %s IFACE IPADDR HOSTNAME PREFIX GATEWAY DNS\n" $SCRIPT
exit 1
}

if [[ $# -eq 0 ]];then
  usage
fi

sed -i "s/DEVICE=.*/DEVICE=${IFACE}/g" $CFG_TEMPLATE
sed -i "s/NAME=.*/NAME=${IFACE}/g" $CFG_TEMPLATE
sed -i "s/IPADDR=.*/IPADDR=${IPADDR}/g" $CFG_TEMPLATE

if [[ ! -z $HOSTNAME ]];then
hostnamectl set-hostname --static $HOSTNAME
fi

if [[ ! -z $PREFIX ]];then 
sed -i "s/PREFIX=.*/PREFIX=${PREFIX}/g" $CFG_TEMPLATE
fi

if [[ ! -z $GATEWAY ]];then 
sed -i "s/GATEWAY=.*/GATEWAY=${GATEWAY}/g" $CFG_TEMPLATE
fi

if [[ ! -z $DNS ]];then 
sed -i "s/DNS1=.*/DNS1=${DNS}/g" $CFG_TEMPLATE
fi

grep -v IPV $CFG_TEMPLATE 

read -p "Zastosowac zmiany? (Y/n) " answer

if [[ $answer == 'Y' ]];then
  cp ${NETCFG_D}/ifcfg-${IFACE}{,_old} && cp $CFG_TEMPLATE ${NETCFG_D}/ifcfg-${IFACE} && systemctl restart network
else
  exit 2;
fi




