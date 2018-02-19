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

function log_it()
# Autor: Aleksandra Angielska
# Funkcja traktuje argumenty jako komendę do wykonania i zapisuje wynik do logu
# Ułatwi to szybka identyfikację, gdzie skrypt napotkał na problem i jest przyjazne monitorowanie
# (jesli grep ERROR $LOG_F | wc -l zwróci 0 wiadomo, ze wszystko przebiegło pomyślnie 
# !!! UWAGA !!! pamietaj o konieczności escape'owania ' i ", np.: log_it psql -t -d postgres -c\"select 1 \" 
    {
                TIME=`date +%Y-%m-%d_%H:%M:%S`
                RETURN=$(eval $* 2>&1)
                EXIT_CODE=$?
        if [ $EXIT_CODE -gt 0 ]; then
            echo $TIME ": ERROR DURING: " $* ", RETURNED: " $RETURN ", EXIT CODE: " $EXIT_CODE >> $LOG_F;
                        if [ $EOE -eq 1 ]; then
                                exit $EXIT_CODE;
                        fi
        else
                        echo $TIME ": " $* ", RETURNED: " $RETURN >> $LOG_F;
                fi
    }

# Sprawdzamy czy zasob zamontowal sie poprawnie
if [ ! -r $CHK_MNT_F ];then
   echo ${TIME_STAMP} " - ERR: MOUNT FAIL" >> ${LOG_F};
   exit 2;
fi

log_it /bin/tar --exclude-from="${SCRIPT_WD}/homefs_exclude.lst" -czvf ${HOMEFS_F} /home/ 

log_it /bin/tar --exclude-from="${SCRIPT_WD}/rootfs_exclude.lst" -czvf ${ROOTFS_F} /

find ${DST_D} -mtime +${RETENTION} -exec rm -rf '{}' \;


