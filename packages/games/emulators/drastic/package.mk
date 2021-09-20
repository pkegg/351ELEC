# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2020-present Shanti Gilbert (https://github.com/shantigilbert)
# Maintenance 2021-present 351ELEC (https://github.com/351ELEC)

PKG_NAME="drastic"
PKG_VERSION="2.5.2.2"
PKG_ARCH="aarch64"
PKG_URL="https://github.com/Cebion/packages/raw/main/misc/drastic.tar.gz"
PKG_SHORTDESC="DraStic DS Emulator"
PKG_TOOLCHAIN="manual"

makeinstall_target() {
  mkdir -p $INSTALL/usr/share/drastic/config/
  if [[ "$DEVICE" == RG351P ]]; then
    cp -rf $PKG_DIR/config/RG351P/drastic.cfg $INSTALL/usr/share/drastic/config/
  elif [[ "$DEVICE" == RG351MP ]]; then
    cp -rf $PKG_DIR/config/RG351V/drastic.cfg $INSTALL/usr/share/drastic/config/
  else
    cp -rf $PKG_DIR/config/RG351V/drastic.cfg $INSTALL/usr/share/drastic/config/
  fi
  mkdir -p $INSTALL/usr/share/drastic/data/
  cp -rf $PKG_BUILD/* $INSTALL/usr/share/drastic/data/
  mkdir -p $INSTALL/usr/bin/
  cp -rf $PKG_DIR/drastic.sh $INSTALL/usr/bin/
}
