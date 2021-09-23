# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="PPSSPPSDL"
PKG_VERSION="914f8899535d278ba3bdf3450c3622ced4f8d2d0"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/hrydgard/ppsspp"
PKG_URL="https://github.com/hrydgard/ppsspp.git"
PKG_DEPENDS_TARGET="toolchain ${OPENGLES} ffmpeg libzip libpng17 SDL2 zlib zip vulkan-loader"
PKG_SHORTDESC="PPSSPPDL"
PKG_LONGDESC="PPSSPP Standalone"
GET_HANDLER_SUPPORT="git"
PKG_BUILD_FLAGS="+lto"

PKG_CMAKE_OPTS_TARGET+="-DUSE_SYSTEM_FFMPEG=OFF \
			-DUSE_WAYLAND_WSI=OFF \
			-DUSE_VULKAN_DISPLAY_KHR=OFF \
			-DUSING_FBDEV=ON \
			-DCMAKE_BUILD_TYPE=Release \
			-DCMAKE_SYSTEM_NAME=Linux \
			-DUSING_EGL=OFF \
			-DUSING_GLES2=ON \
			-DVULKAN=OFF \
			-DARM_NO_VULKAN=ON \
			-DUSING_X11_VULKAN=OFF \
			-DBUILD_SHARED_LIBS=OFF \
			-DANDROID=OFF \
			-DWIN32=OFF \
			-DAPPLE=OFF \
			-DCMAKE_CROSSCOMPILING=ON \
			-DUSING_QT_UI=OFF \
			-DUNITTEST=OFF \
			-DSIMULATOR=OFF \
			-DHEADLESS=OFF \
			-DUSE_DISCORD=OFF \
			-fpermissive"

pre_configure_target() {
  sed -i "s|include_directories(/usr/include/drm)|include_directories(${SYSROOT_PREFIX}/usr/include/drm)|" $PKG_BUILD/CMakeLists.txt
}

pre_make_target() {
  export CPPFLAGS="${CPPFLAGS} -Wno-error"
  export CFLAGS="${CFLAGS} -Wno-error"

  # fix cross compiling
  find ${PKG_BUILD} -name flags.make -exec sed -i "s:isystem :I:g" \{} \;
  find ${PKG_BUILD} -name build.ninja -exec sed -i "s:isystem :I:g" \{} \;
}

makeinstall_target() {
  mkdir -p $INSTALL/usr/bin
    cp $PKG_DIR/ppsspp.sh $INSTALL/usr/bin/ppsspp.sh
    cp `find . -name "PPSSPPSDL" | xargs echo` $INSTALL/usr/bin/PPSSPPSDL
    ln -sf /storage/.config/ppsspp/assets $INSTALL/usr/bin/assets
    mkdir -p $INSTALL/usr/config/ppsspp/
    cp -r `find . -name "assets" | xargs echo` $INSTALL/usr/config/ppsspp/
    cp -rf $PKG_DIR/config/* $INSTALL/usr/config/ppsspp/
}
