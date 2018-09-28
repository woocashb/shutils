#!/bin/bash -x

#
# Autor: lboczkaja@unity-t.pl
#
# Opis: Skrypt do backupowania systemu

DST_D=/mnt/backup
CHK_MNT_F=${DST_D}/mount_test
SCRIPT=$(basename -- ${0})
LOG_F=/var/log/skrypty/${SCRIPT}.log
TIME_STAMP=$(date "+%F")
BCKP_SUFFIX=${TIME_STAMP}.tar.gz
HOMEFS_F=${DST_D}/homefs_${BCKP_SUFFIX}
ROOTFS_F=${DST_D}/rootfs_${BCKP_SUFFIX}
SCRIPT_WD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
RETENTION=14
GZIP=-6

# Sprawdzamy czy zasob zamontowal sie poprawnie
if [ ! -r $CHK_MNT_F ];then
   echo ${TIME_STAMP} " - ERR: MOUNT FAIL" >> ${LOG_F};
   exit 2;
fi

#log_it /bin/tar --exclude-from="${SCRIPT_WD}/homefs_exclude.lst" -czvf ${HOMEFS_F} /home/ 

log_it /bin/tar --exclude-from="${SCRIPT_WD}/rootfs_exclude.lst" -czvf ${ROOTFS_F} /

find ${DST_D} -mtime +${RETENTION} -exec rm -rf '{}' \;


