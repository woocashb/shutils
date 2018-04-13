#!/bin/bash

# Autor: Łukasz Boczkaja
# Mail: lboczkaja@unity-t.pl
# Opis: skrypt automatyzujacy tworzenie/usuwanie uzytkownikow domenowych




# wyciągnij pozycje na ktorej znajduje sie kolejny numer dla uzytkownika

argc=$#
action=$1
name=$2
group=$3
NETBIOS_NAME=$(hostname | cut -d '.' -f1 | tr "[:lower:]" "[:upper:]")

NO_SUCH_GROUP=2
NO_SUCH_USER=3
USER_DEL_ABORT=4
NO_SUCH_OPTION=5

get_nr_pos(){
count=0
num_re="^[0-9]+$"

for token in $(echo $LAST_USER | tr '-' '\n');
do
  let count+=1;
  if [[ $token =~ $num_re ]];then
  LAST_NR=$token
  break
  fi
done
}

usage(){
printf "Dodaj/usun/listuj uzytkownika domenowego\n#1 Dodaj:\t$0 -a CZLON_NAZWY_UZYTKOWNIKA GRUPA\nPrzyklad uzycia: $0 -a audy audyt # Utworzy nowa nazwe uzytkownika audy-(n+1) i doda go do grupy audyt\n
#2 Usun:\t$0 -r PELNA_NAZWA_UZYTKOWNIKA\n
#3 Listuj:\t$0 -l PELNA_NAZWA_UZYKOWNIKA
"
exit 1
}


add(){
USERS_D=/home/users

chk_add_arg $#
#netlogon=${3:-$2}.bat


LAST_USER=$(smbldap-userlist | cut -d '|' -f2 | grep -v '\$' | egrep $name | tail -n 1)
get_nr_pos
USR_NAME=$(echo $LAST_USER | awk -F ${LAST_NR} '{print $1}')
NEW_NR=$((LAST_NR + 1))

NEXT_USR_NAME=${USR_NAME}${NEW_NR}
NEXT_USR_PWD=$(openssl rand -base64 3)

smbldap-useradd -a -E ${group}.bat -d ${USERS_D}/${group}/${NEXT_USR_NAME} -F "\\\\$NETBIOS_NAME\${NEXT_USR_NAME}\\profiles" -g $group -G $group -m -s /bin/false -D Q: -B 0 $NEXT_USR_NAME > /dev/null 2>&1
echo "$NEXT_USR_PWD" | smbldap-passwd -p $NEXT_USR_NAME
pdbedit -c '[X]' $NEXT_USR_NAME > /dev/null 2>&1
smbldap-usermod $NEXT_USR_NAME --sambaProfilePath \\\\${NETBIOS_NAME}\\${NEXT_USR_NAME}\\profiles
smbldap-usermod $NEXT_USR_NAME --sambaHomePath \\\\${NETBIOS_NAME}\\${NEXT_USR_NAME}

printf "Utworzono nowego uzytkownika\nnazwa:\t%s\nhaslo:\t%s\n" $NEXT_USR_NAME $NEXT_USR_PWD
}

remove(){
chk_remove_arg $#
echo "Usunac uzytkownika \"$name\" wraz z jego katalogiem domowym? (yes/no)"
read answer

case $answer in
  yes) smbldap-userdel -r $name && echo "Uzytkownik \"$name\" usuniety." ;;
  no) exit $USER_DEL_ABORT ;;
  *) exit $NO_SUCH_OPTION ;;
esac 
exit 0
}

list(){
if [[ -z $name ]];then
  usage
fi
smbldap-usershow $name && echo "ID uzytkownika:" && id $name
exit 0
}

chk_remove_arg(){
remove_argc=$1
if [[ $remove_argc -ne 1 ]];then
  usage
fi
smbldap-usershow $name > /dev/null 2>&1
usr_valid=$?
if [[ $usr_valid -eq 1 ]];then
  echo "ERROR: Uzytkownik o nazwie \"$name\" nie istnieje"
  usage
  exit $NO_SUCH_USER
fi

}

chk_add_arg(){
add_argc=$1
smbldap-groupshow $group > /dev/null 2>&1
grp_valid=$?
if [[ $add_argc -ne 2 ]];then
  usage
  exit 1
fi
if [[ $grp_valid -eq 1 ]];then
  echo "ERROR: Grupa o nazwie \"$group\" nie istnieje"
  usage
  exit $NO_SUCH_GROUP
fi
}

if [[ $argc -eq 0 ]];then
  usage
fi

while getopts "arlh:" action;
do
  case $action in
  a) add $name $group ;; 
  r) remove $name ;;
  l) list $name ;;
  \?) usage ;;
  esac
done

