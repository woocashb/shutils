#!/bin/bash


#PROC_NUM=$( ps -A --no-headers | wc -l)
#TRIGGER=200


LOG_D=/var/log/scripts/
if [[ ! -r $LOG_D ]];then
  mkdir -p $LOG_D;
fi

OUTPUT_F=${LOG_D}/monitor.log

TIME_STAMP=$(date "+%F_%T")
SEP=$(printf '=%.0s' {1..100})
HEADER=$(printf "%s\n%s\n%s\n" $SEP $TIME_STAMP $SEP)

PROGS=(
"pstree" 
"sar -r" 
"sar -q" 
"sar -n DEV | egrep -v 'lo|eth1'"
"dmesg" 
"sensors"  
"smartctl -a /dev/sda"
"lsof | wc -l"
"iptables -vnL"
)

echo $HEADER >> $OUTPUT_F

for prog in "${PROGS[@]}";do
 printf "%s %s %s" $SEP "$prog" $SEP >> $OUTPUT_F
 echo "" >> $OUTPUT_F
 bash -c "$prog" >> $OUTPUT_F
 echo $SEP
done
