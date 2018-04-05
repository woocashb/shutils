#!/usr/bin/bash 

argc=$#
tag=$2
ip=$3
usr=$4
proxy=$5

SSH_CFG=~/.ssh/config

USAGE_FAIL=1
TAG_DUPLICATE=2
BACKUP_FAIL=3

ENTRY_TEMPLATE=$(printf "
Host $tag
  HostName $ip
  User $usr
"
)

add(){
chk_add_arg $#
if [[ ! -z $proxy ]];then
  ENTRY_PROXY="ProxyCommand ssh -q -W %h:%p $proxy"
  ENTRY_TEMPLATE=$(printf "%s\n  %s\n" "$ENTRY_TEMPLATE" "$ENTRY_PROXY")
fi

(printf "\n%s" "$ENTRY_TEMPLATE" >> $SSH_CFG) && ssh-copy-id $tag
exit 0;
}

chk_add_arg(){
ADD_ARGC=$1
if [[ $ADD_ARGC -lt 3 ]];then
  usage
fi

if [[ $(grep -c -i " $tag" $SSH_CFG) -ne 0 ]];then
  echo "Etykieta \"$tag\" juz istnieje."
  exit $TAG_DUPLICATE
fi
return 0
}

remove(){
cp -p $SSH_CFG ${SSH_CFG}.backup
chk_remove_arg $#
# Usun caly wpis uwzgledniajac ewentualny parametr ProxyCommand
if [[ $(list | grep -c -i 'ProxyCommand') -ne 0 ]];then
 sed -i "/${tag}/,+3d" $SSH_CFG
else
  sed -i "/${tag}/,+2d" $SSH_CFG
fi

exit 0
}

chk_remove_arg(){
REMOVE_ARGC=$1
if [[ $REMOVE_ARGC -ne 1 ]];then
  usage
fi

if [[ ! -e ${SSH_CFG}.backup ]];then
  echo "Tworzenie backupu pliku konfiguracyjnego nie powiodlo sie. Przerywam usuwanie."
  exit $BACKUP_FAIL
fi
}
list(){
grep -A 3 -i "Host $tag" $SSH_CFG
exit 0
}

usage(){
printf "
Dodaj/usun/listuj wpisy dla hostow w ~/.ssh/config
sshcfg_mgr.sh [-a] host_tag ip_address user_name [proxy_host]
              [-r] host_tag
              [-l] host_tag
"
exit $USAGE_FAIL;
}

if [[ $argc -eq 0 ]];then
  usage
fi

while getopts "arl:" action;do
     case $action in
        a) add $tag $ip $usr $proxy;;
        r) remove $tag ;;
        l) list $tag ;;
        \?) usage ;;
     esac
done


