#!/bin/bash

# Bash Color
green='\033[01;32m'
red='\033[01;31m'
blink_red='\033[05;31m'
restore='\033[0m'

clear

# Resources
THREAD="-j$(grep -c ^processor /proc/cpuinfo)"
KERNEL="Image.gz"
DTBOIMG="dtbo.img"

# Defconfigs
LMIDEFCONFIG="yarpiin_lmi_defconfig"

# Build dirs
KERNEL_DIR="$(pwd)"
RESOURCE_DIR="$KERNEL_DIR/.."
KERNELFLASHER_DIR="$KERNEL_DIR/AnyKernel3"
MODULES_DIR="$KERNELFLASHER_DIR/modules/system/lib/modules"

# Toolchain paths
CLANG_DIR="$KERNEL_DIR/Toolchains/clang/bin"
GCC_DIR="$KERNEL_DIR/Toolchains/gcc/bin"

# Kernel Details
YARPIIN_VER="WHITE WOLF KERNEL UNI"
BASE_YARPIIN_VER="WHITE.WOLF.S."
LMI_VER="LMI"
VER=".009"
YARPIIN_LMI_VER="$BASE_YARPIIN_VER$LMI_VER$VER"

# Vars
export ARCH=arm64
export SUBARCH=arm64
export KBUILD_BUILD_USER=ZenkaBestia
export KBUILD_BUILD_HOST=Linux-VM

# Image dirs
ZIMAGE_DIR="$KERNEL_DIR/out/arch/arm64/boot"

# Output dir
ZIP_MOVE="$KERNEL_DIR/Zip"

# Functions
function clean_all {

		if [ -f "$MODULES_DIR/*.ko" ]; then
			rm `echo $MODULES_DIR"/*.ko"`
		fi
		if [ -f "$KERNELFLASHER_DIR/$KERNEL" ]; then
		    rm `echo $KERNELFLASHER_DIR/$KERNEL`
        fi
		if [ -f "$KERNELFLASHER_DIR/$DTBOIMG" ]; then
		    rm `echo $KERNELFLASHER_DIR/$DTBOIMG`
        fi
		cd $KERNEL_DIR
		echo
		make clean && make mrproper
        rm -rf out/
}

function make_lmi_kernel {
		echo
        export LOCALVERSION=-`echo $YARPIIN_LMI_VER`
        export TARGET_PRODUCT=lmi
        make O=out ARCH=arm64 $LMIDEFCONFIG

        PATH="$CLANG_DIR:$GCC_DIR:${PATH}" \
        make -j$(nproc --all) O=out \
                      ARCH=arm64 \
                      CC=clang \
                      CLANG_TRIPLE=aarch64-linux-gnu- \
                      CROSS_COMPILE=aarch64-linux-android-

		cp -vr $ZIMAGE_DIR/$KERNEL $KERNELFLASHER_DIR
		cp -vr $ZIMAGE_DIR/$DTBOIMG $KERNELFLASHER_DIR
        find ${KERNEL_DIR} -name '*.ko' -exec cp -v {} ${MODULES_DIR} \;
}

function make_lmi_zip {
		cd $KERNELFLASHER_DIR
		zip -r9 `echo $YARPIIN_LMI_VER`.zip *
                mkdir $ZIP_MOVE
		mv  `echo $YARPIIN_LMI_VER`.zip $ZIP_MOVE/`echo $YARPIIN_LMI_VER-$(date +"%d%m%y")`.zip
		cd $KERNEL_DIR
}

DATE_START=$(date +"%s")

echo -e "${green}"
echo "YARPIIN Kernel Creation Script:"
echo

echo "---------------------------"
echo "Kernel Version:"
echo "---------------------------"

echo -e "${red}"; echo -e "${blink_red}"; echo "$YARPIIN_VER"; echo -e "${restore}";

echo -e "${green}"
echo "---------------------------"
echo "Building White Wolf Kernel:"
echo "---------------------------"
echo -e "${restore}"

while read -p "Do you want to clean stuffs (y/n)? " cchoice
do
case "$cchoice" in
	y|Y )
		clean_all
		echo
		echo "All Cleaned now."
		break
		;;
	n|N )
		break
		;;
	* )
		echo
		echo "Invalid try again!"
		echo
		;;
esac
done

echo "Starting to build POCO F2 Pro kernel"
		make_lmi_kernel
echo

while read -p "Do you want to zip POCO F2 Pro kernel (y/n)? " dchoice
do
case "$dchoice" in
	y|Y)
		make_lmi_zip
		break
		;;
	n|N )
		break
		;;
	* )
		echo
		echo "Invalid try again!"
		echo
		;;
esac
done

echo

while read -p "Do you want to clean stuffs (y/n)? " cchoice
do
case "$cchoice" in
	y|Y )
		clean_all
		echo
		echo "All Cleaned now."
		break
		;;
	n|N )
		break
		;;
	* )
		echo
		echo "Invalid try again!"
		echo
		;;
esac
done

echo

echo
echo
echo -e "${green}"
echo "-------------------"
echo "Build Completed in:"
echo "-------------------"
echo -e "${restore}"

DATE_END=$(date +"%s")
DIFF=$(($DATE_END - $DATE_START))
echo "Time: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
echo

