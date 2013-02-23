#!/sbin/busybox sh
/sbin/busybox mount -t rootfs -o remount,rw rootfs

/sbin/busybox cp /data/Litekernel.log /data/.Litekernel.log.old
/sbin/busybox rm /data/Litekernel.log
exec >>/data/Litekernel.log
exec 2>&1

##### KERNEL SETUP #####

/sbin/busybox sh /sbin/ext/kernel-init

##### RUN GENERAL SCRIPTS #####

KERNELTWEAKS="`cat /data/LiteKernel/Kernel_Tweaks`"; 
if [ "$KERNELTWEAKS" -eq 1 ]; then
/sbin/busybox sh /sbin/ext/kernel-tweaks
fi

FIXALIGNMENT="`cat /data/LiteKernel/FixAlignment`"; 
if [ "$FIXALIGNMENT" -eq 1 ]; then
/sbin/busybox sh /sbin/ext/FixAlignment.sh
fi

GENERALTWEAKS="`cat /data/LiteKernel/General_Tweaks`"; 
if [ "$GENERALTWEAKS" -eq 1 ]; then
/sbin/busybox sh /sbin/ext/general-tweaks
fi

/sbin/busybox sh /sbin/LiteKernel_Manager

##### EFS BACKUP #####
(
sleep 30
/sbin/busybox sh /sbin/ext/efs-backup
) &

##### CLEAN MEMORY #####
CLEANMEMORY="`cat /data/LiteKernel/Advanced/MEMORY_CLEAN`"; 
if [ "$CLEANMEMORY" -eq 1 ]; then
(
sleep 55
/sbin/busybox sh /sbin/FastEngineFlush.sh
) &
fi

##### REMOVE SCRIPTS #####
(
sleep 60
/sbin/busybox sh /sbin/init
) &
