#!/bin/bash

# Build kernel
git clone -b 2019_R2 --depth=1 https://github.com/analogdevicesinc/linux.git
cd linux
export ARCH=arm
export CROSS_COMPILE=arm-linux-gnueabihf-
source /opt/Xilinx/Vivado/2019.1/settings64.sh
cp ../hopper.patch .
git apply hopper.patch
make zynq_xcomm_adv7511_defconfig
make -j4 UIMAGE_LOADADDR=0x8000 uImage
