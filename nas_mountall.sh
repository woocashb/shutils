#!/bin/bash 

NAS_IP=$1
MOUNT_ROOT=${2%/}
CLEAN=${3:-'false'}
ARGC=$#

usage(){
SCRIPT=$(basename $0)
printf "$SCRIPT IP MOUNT_DIR [CLEAN={false,true}]\n"
}

if [[ $ARGC -lt 2 ]];then
  usage
  exit 1;
fi

shares=$(showmount -e $NAS_IP | tail -n +2 | awk '{print $1}')


shares_mount(){
for share in ${shares[@]};do
        share_leaf_dir=$(basename $share)
        ( [ ! -d ${MOUNT_ROOT}/${share_leaf_dir} ] && mkdir ${MOUNT_ROOT}/${share_leaf_dir}) && mount -t nfs ${NAS_IP}:${share} ${MOUNT_ROOT}/${share_leaf_dir};
done
}
shares_umount(){
for share in ${shares[@]};do
	share_leaf_dir=$(basename $share)
	umount ${MOUNT_ROOT}/${share_leaf_dir}
	[ -d ${MOUNT_ROOT}/${share_leaf_dir} ] && rmdir ${MOUNT_ROOT}/${share_leaf_dir}
done
}

case $ARGC in
   2) shares_mount
   ;;
   3) if [ $CLEAN == 'true' ];then 
        shares_umount;
      else
      usage
      fi
   ;;
   *) usage
   ;;
esac

