#! /bin/bash

echo
date
echo "Starting Script"
echo 

cd ..

#export CROSS_COMPILE=/opt/toolchains/android-toolchain-eabi/bin/arm-eabi-
export CROSS_COMPILE=/opt/toolchains/arm-eabi-linaro-4.7.3/bin/arm-eabi-

# get current version
VERSION=`date +%Y%m%d`

KERNEL_NAME="LiteKernel"
KERNEL_NAME2="-4.2-"

export LOCALVERSION="-$KERNEL_NAME"
export KBUILD_BUILD_VERSION="$VERSION"
#export WHOAMI_MOD="TheGreaterGood"
export HOSTNAME_MOD="TheGreaterGood"

make tegra_bose_defconfig

echo
date
echo "Compiling Kernel"
echo 

make -j8

echo
echo "Packaging Kernel"
echo

cp -a ./arch/arm/boot/zImage ./Build4.2

cp -a ./drivers/net/wireless/bcmdhd/dhd.ko ./Build4.2/ramdisk/lib/modules

cp -a ./drivers/scsi/scsi_wait_scan.ko ./Build4.2/ramdisk/lib/modules

cp -a ./drivers/misc/fm_si4709/Si4709_driver.ko ./Build4.2/ramdisk/lib/modules

#cp -a ./drivers/nfc/pn544.ko ./Build4.2/ramdisk/lib/modules

cd ./Build4.2


echo
echo "building Ramdisk"
echo

cd ramdisk

find . | cpio -o -H newc | gzip > ../newramdisk.cpio.gz
cd ..

./mkbootimg --kernel zImage --ramdisk newramdisk.cpio.gz --base 0x81600000 --kernelMD5 3751cc8e6e4d4b3da0017a725bfe5aed -o boot.img

cp -a boot.img /home/cody/Desktop/KERNEL/Auto-Sign/boot.img
tar -cf newboot.tar boot.img
cp -a ./boot.img /mnt/hgfs/LiteKernel--4.2-OUTPUT

ZIP_NAME="$KERNEL_NAME$KERNEL_NAME2$KBUILD_BUILD_VERSION.zip"
CWM_ZIP="4.2.cwmzip"

# Create CWM File

cd /home/cody/Desktop/KERNEL/Auto-Sign/
cp -a $CWM_ZIP $ZIP_NAME
zip $ZIP_NAME boot.img
java -jar signapk.jar testkey.x509.pem testkey.pk8 $ZIP_NAME ../$ZIP_NAME

cp -a ./$ZIP_NAME /mnt/hgfs/LiteKernel--4.2-OUTPUT

echo
date
echo "Finished"
echo
bash
