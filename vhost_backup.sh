#!/bin/bash 

TIMESTAMP=$(date -I)
# kody bledow
MOUNT_FAIL=1

# lokalizacje
BACKUP_ROOT_DIR=/automounter
BACKUP_DIR=${BACKUP_ROOT_DIR}/backupWEB/${TIMESTAMP}
MOUNT_TEST=/automounter/backupWEB/mount_test
LOG_ROOT=/var/log/scripts
LOG_DIR=${LOG_ROOT}/$(basename $0)
DOC_ROOT=/var/www/html

# binarki
BACKUP_BIN=$(which tar)

[ ! -d $LOG_DIR ] && mkdir -p $LOG_DIR
[ ! -d $BACKUP_DIR ] && mkdir -p $BACKUP_DIR
[ ! -r $MOUNT_TEST ] && echo "$TIMESTAMP - MOUNT FAIL" >> ${LOG_DIR}/montowanie.log && exit $MOUNT_FAIL

VHOST_LIST=$(ls $DOC_ROOT)

for vhost in ${VHOST_LIST};do
   $BACKUP_BIN -czf ${BACKUP_DIR}/${vhost}.tar.gz ${DOC_ROOT}/$vhost
done

