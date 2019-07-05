#!/bin/bash 

TIMESTAMP=$(date -I)

# kody bledow
MOUNT_FAIL=1

# lokalizacje
BACKUP_ROOT_DIR=/automounter
BACKUP_DIR=${BACKUP_ROOT_DIR}/mysql/${TIMESTAMP}
MOUNT_TEST=/automounter/mysql/mount_test
LOG_ROOT=/var/log/scripts
LOG_DIR=${LOG_ROOT}/$(basename $0)

# konfiguracja polaczenia
USER=root
PWD=
HOST=127.0.0.1

# binarki
CLIENT=$(which mysql)
DUMP_BIN=$(which mysqldump)

[ ! -d $LOG_DIR ] && mkdir -p $LOG_DIR
[ ! -d $BACKUP_DIR ] && mkdir -p $BACKUP_DIR
[ ! -r $MOUNT_TEST ] && echo "$TIMESTAMP - MOUNT FAIL" >> ${LOG_DIR}/montowanie.log && exit $MOUNT_FAIL

DB_LIST=$($CLIENT -u $USER -p${PWD} -e 'SHOW DATABASES;' | egrep -Ev 'Database|schema')

for db in $DB_LIST;do
  $DUMP_BIN -u $USER -p$PWD $db > ${BACKUP_DIR}/${db}.dump ;
done

# retencja 2 tygodnie
find $BACKUP_DIR -maxdepth 1 -type f -mtime +14 -exec rm '{}' \;

