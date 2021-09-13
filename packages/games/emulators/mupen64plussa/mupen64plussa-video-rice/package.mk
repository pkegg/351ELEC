# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="mupen64plussa-video-rice"
PKG_VERSION="8cd53f0272cd3cd44510a01fd0aedcb7e5df0790"
PKG_ARCH="any"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/mupen64plus/mupen64plus-video-rice"
PKG_URL="https://github.com/mupen64plus/mupen64plus-video-rice/archive/${PKG_VERSION}.tar.gz"
PKG_SHA256="3a7fa1da2a7b58862057d7e18910be611a11474ea82dfcc9a3e4b52c03b56007"
PKG_DEPENDS_TARGET="toolchain ${OPENGLES} libpng17 SDL2 SDL2_net zlib freetype nasm:host mupen64plussa-core"
PKG_SHORTDESC="mupen64plus-video-rice"
PKG_LONGDESC="Mupen64Plus Standalone Rice Video Driver"
PKG_TOOLCHAIN="manual"

PKG_MAKE_OPTS_TARGET+="USE_GLES=1"

make_target() {
  export HOST_CPU=aarch64
  export APIDIR=$(get_build_dir mupen64plussa-core)/.install_pkg/usr/local/include/mupen64plus
  export USE_GLES=1
  export SDL_CFLAGS="-I$SYSROOT_PREFIX/usr/include/SDL2 -D_REENTRANT"
  export SDL_LDLIBS="-lSDL2_net -lSDL2"
  export CROSS_COMPILE="$TARGET_PREFIX"
  export V=1
  export VC=0
  BINUTILS="$(get_build_dir binutils)/.aarch64-libreelec-linux-gnueabi"
  make -C projects/unix clean
  make -C projects/unix all ${PKG_MAKE_OPTS_TARGET}
}

makeinstall_target() {
  UPREFIX=${INSTALL}/usr/local
  ULIBDIR=${UPREFIX}/lib
  USHAREDIR=${UPREFIX}/share/mupen64plus
  UPLUGINDIR=${ULIBDIR}/mupen64plus
  mkdir -p ${UPLUGINDIR}
  cp ${PKG_BUILD}/projects/unix/mupen64plus-video-rice.so ${UPLUGINDIR}
  #$STRIP ${UPLUGINDIR}/mupen64plus-video-rice.so
  chmod 0644 ${UPLUGINDIR}/mupen64plus-video-rice.so
  mkdir -p ${USHAREDIR}
  cp ${PKG_BUILD}/data/RiceVideoLinux.ini ${USHAREDIR}
  chmod 0644 ${USHAREDIR}/RiceVideoLinux.ini
}

