#! /bin/bash

cd ..

export CROSS_COMPILE=/opt/toolchains/arm-eabi-linaro-4.7.3/bin/arm-eabi-

make tegra_bose_defconfig

make menuconfig

bash
