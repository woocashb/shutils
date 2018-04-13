#!/bin/bash -x


PROC_NUM=$( ps -A --no-headers | wc -l)
TRIGGER=300

#if [[ $PROC_NUM < $TRIGGER ]]then
#  exit 1
#fi

OUTPUT_F=./monitor.log
TIME_STAMP=$(date "+%F_%T")
SEP=$(printf '=%.0s' {1..100})
HEADER=$(printf "%s\n%s\n%s\n" $SEP $TIME_STAMP $SEP)

PROGS=(
"pstree" 
"sar -r" 
"sar -q" 
"dmesg" 
"sensors"  
"smartctl -a /dev/sda"
)

echo $HEADER >> $OUTPUT_F

for prog in "${PROGS[@]}";do
 printf "%s %s %s" $SEP "$prog" $SEP >> $OUTPUT_F
 echo "" >> $OUTPUT_F
 bash -c "$prog" >> $OUTPUT_F
 echo $SEP
done
