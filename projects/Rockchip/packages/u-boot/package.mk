# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2017-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="u-boot"
PKG_ARCH="arm aarch64"
PKG_LICENSE="GPL"
PKG_SITE="https://www.denx.de/wiki/U-Boot"
PKG_DEPENDS_TARGET="toolchain swig:host rkbin"
PKG_LONGDESC="Das U-Boot is a cross-platform bootloader for embedded systems."

PKG_IS_KERNEL_PKG="yes"
PKG_STAMP="$UBOOT_SYSTEM"

[ -n "$ATF_PLATFORM" ] && PKG_DEPENDS_TARGET+=" atf"

PKG_NEED_UNPACK="$PROJECT_DIR/$PROJECT/bootloader"
[ -n "$DEVICE" ] && PKG_NEED_UNPACK+=" $PROJECT_DIR/$PROJECT/devices/$DEVICE/bootloader"

if [[ "$DEVICE" =~ RG351 ]]; then
  PKG_VERSION="9079d0b8b34507505487321c499222f4be9be501"
  PKG_GIT_CLONE_SINGLE="yes"
  PKG_GIT_CLONE_DEPTH="1"
  PKG_URL="https://github.com/AmberELEC/uboot_rg351.git"
elif [[ "$DEVICE" =~ RG552 ]]; then
  PKG_VERSION="734ad933766f0dbbeafe1b27211686940a5e6d16"
  PKG_GIT_CLONE_BRANCH=v2022.01-rc4
  PKG_GIT_CLONE_SINGLE="yes"
  PKG_GIT_CLONE_DEPTH="1"
  PKG_URL="https://github.com/u-boot/u-boot.git"
elif [[ "$DEVICE" =~ RG353P ]]; then
  PKG_VERSION="dfd1bcb"
  PKG_GIT_CLONE_BRANCH=main
  PKG_URL="https://github.com/JustEnoughLinuxOS/rk356x-uboot.git"
fi


post_patch() {
  if [ -n "$UBOOT_SYSTEM" ] && find_file_path bootloader/config; then
    PKG_CONFIG_FILE="$PKG_BUILD/configs/$($ROOT/$SCRIPTS/uboot_helper $PROJECT $DEVICE $UBOOT_SYSTEM config)"
    if [ -f "$PKG_CONFIG_FILE" ]; then
      cat $FOUND_PATH >> "$PKG_CONFIG_FILE"
    fi
  fi
}

make_target() {
  . ${PROJECT_DIR}/${PROJECT}/devices/${DEVICE}/options

  if [ -z "$UBOOT_SYSTEM" ]; then
    echo "UBOOT_SYSTEM must be set to build an image"
    echo "see './scripts/uboot_helper' for more information"
  elif [ "$DEVICE" == "RG353P" ]
    then
      UBOOT_DTB="rk3566"
      echo "woooooord: $UBOOT_DTB $TOOLCHAIN"

      cd ${PKG_BUILD}
      git checkout -- include/configs/rockchip-common.h
      sed -i "s|JELOS|AMBRELC/bin|" make.sh

      git checkout -- make.sh

      echo "Making for GPT (${UBOOT_DTB})..."
      sed -i "s|TOOLCHAIN_ARM64=.*|TOOLCHAIN_ARM64=${TOOLCHAIN}/bin|" make.sh
      sed -i "s|aarch64-linux-gnu|${TARGET_NAME}|g" make.sh
      sed -i "s|../rkbin|$(get_build_dir rkbin)|" make.sh
      ./make.sh ${UBOOT_DTB}
      echo "done"
  else
    [ "${BUILD_WITH_DEBUG}" = "yes" ] && PKG_DEBUG=1 || PKG_DEBUG=0
    [ -n "$ATF_PLATFORM" ] &&  cp -av $(get_build_dir atf)/bl31.bin .
    DEBUG=${PKG_DEBUG} CROSS_COMPILE="$TARGET_KERNEL_PREFIX" LDFLAGS="" ARCH=arm make mrproper
    DEBUG=${PKG_DEBUG} CROSS_COMPILE="$TARGET_KERNEL_PREFIX" LDFLAGS="" ARCH=arm make $($ROOT/$SCRIPTS/uboot_helper $PROJECT $DEVICE $UBOOT_SYSTEM config)
    DEBUG=${PKG_DEBUG} CROSS_COMPILE="$TARGET_KERNEL_PREFIX" LDFLAGS="" ARCH=arm _python_sysroot="$TOOLCHAIN" _python_prefix=/ _python_exec_prefix=/ make HOSTCC="$HOST_CC" HOSTLDFLAGS="-L$TOOLCHAIN/lib" HOSTSTRIP="true" CONFIG_MKIMAGE_DTC_PATH="scripts/dtc/dtc"
  fi
}

makeinstall_target() {
    echo "install target___"
    mkdir -p $INSTALL/usr/share/bootloader
        echo "find target___"

    # Only install u-boot.img et al when building a board specific image
    if [ -n "$UBOOT_SYSTEM" ]; then
      find_file_path bootloader/install && . ${FOUND_PATH}
    fi
          echo "can target___"

    # Always install the update script
    find_file_path bootloader/update.sh && cp -av ${FOUND_PATH} $INSTALL/usr/share/bootloader
    echo "install canupdate"
    # Always install the canupdate script
    if find_file_path bootloader/canupdate.sh; then
      cp -av ${FOUND_PATH} $INSTALL/usr/share/bootloader
      sed -e "s/@PROJECT@/${DEVICE:-$PROJECT}/g" \
          -i $INSTALL/usr/share/bootloader/canupdate.sh
    fi
    if [ "$DEVICE" == "RG351P" ]; then
      cp -f $PKG_BUILD/arch/arm/dts/rg351p-uboot.dtb $INSTALL/usr/share/bootloader
    elif [ "$DEVICE" == "RG351V" ]; then
      cp -f $PKG_BUILD/arch/arm/dts/rg351v-uboot.dtb $INSTALL/usr/share/bootloader
    elif [ "$DEVICE" == "RG351MP" ]; then
      cp -f $PKG_BUILD/arch/arm/dts/rg351mp-uboot.dtb $INSTALL/usr/share/bootloader
    fi
}
