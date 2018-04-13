#!/bin/bash


argc=$#
name=$2

NETLOGON_D=/etc/samba/netlogon
skel_bat_f=${NETLOGON_D}/skel.bat

USERS_D=/home/users

add(){
# netlogon
name=$1

cp $skel_bat_f $NETLOGON_D/${name}.bat
sed -i "s/NAZWA_GRUPY/${name}/g" ${NETLOGON_D}/${name}.bat

# dodaj nowa grupe
smbldap-groupadd -a $name

if [[ ! -d ${USERS_D}/${name} ]];then
	mkdir ${USERS_D}/${name}
	chown root:${name} ${USERS_D}/${name} && chmod 770 ${USERS_D}/$name
fi
}

remove(){
name=$1
if [[ -e ${NETLOGON_D}/${name}.bat ]];then
  rm -i ${NETLOGON_D}/${name}.bat
fi
if [[ -d ${USERS_D}/${name} ]];then
  rmdir $USERS_D/${name};
fi

smbldap-groupdel $name

}

list(){
if [[ -z $name ]];then
  usage
fi
smbldap-groupshow $name | grep -i "memberUid"
exit 0
}

usage(){
printf "Dodaj/Usun/Listuj grupe uzytkownikow domenowych
#1 Dodaj: $0 -a NAZWA_GRUPY

#2 Usun:  $0 -r NAZWA_GRUPY

#3 Listuj: $0 -l NAZWA_GRUPY
"
exit 1
}

if [[ $# -ne 2 ]];then
  usage
fi

while getopts "arl:" action;do
     case $action in
        a) add $name ;;
        r) remove $name ;;
        l) list $name ;;
        \?) usage ;;
     esac
done

