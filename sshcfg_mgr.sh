#!/usr/bin/bash -x

tag=$2
ip=$3
usr=$4
proxy=$5

SSH_CFG=~/.ssh/configtest

USAGE_FAIL=1
TAG_DUPLICATE=2


ENTRY_TEMPLATE=$(printf "
Host $tag
  HostName $ip
  User $usr
"
)

add(){
chk_add_arg
if [[ ! -z $proxy ]];then
  ENTRY_PROXY="ProxyCommand ssh -q -W %h:%p $proxy"
  ENTRY_TEMPLATE=$(printf "%s\n  %s\n" "$ENTRY_TEMPLATE" "$ENTRY_PROXY")
fi

printf "\n%s" "$ENTRY_TEMPLATE" >> $SSH_CFG

exit 0;
}

chk_add_arg(){
if [[ $(grep -c -i " $tag" $SSH_CFG) -ne 0 ]];then
  echo "Etykieta \"$tag\" juz istnieje."
  exit $TAG_DUPLICATE
fi
return 0
}

remove(){
cp -p $SSH_CFG ${SSH_CFG}.backup
sed -i "/${tag}/,+3d" $SSH_CFG

exit 0
}

list(){
grep -A 4 -i $tag $SSH_CFG
exit 0
}

usage(){
printf "
Dodaj/usun wpisy dla hostow w ~/.ssh/config
sshcfg [-a] host_tag ip_address user_name [proxy_host]
       [-r] host_tag
"
exit $USAGE_FAIL;
}

while getopts "arl:" action;do
     case $action in
        a) add $tag $ip $usr $proxy;;
        r) remove $tag ;;
        l) list $tag ;;
        \?) usage ;;
     esac
done

usage

