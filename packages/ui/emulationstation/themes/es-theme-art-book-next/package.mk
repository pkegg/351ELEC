# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2020 Shanti Gilbert (https://github.com/shantigilbert)
# Copyright (C) 2021 AmberELEC (https://github.com/AmberELEC)

PKG_NAME="es-theme-art-book-next"
PKG_REV="1"
PKG_VERSION="2b6d721366b3dac0381e949c876202f231fd5563"
PKG_ARCH="any"
PKG_LICENSE="CUSTOM"
PKG_SITE="https://github.com/anthonycaccese/es-theme-art-book-next"
PKG_URL="$PKG_SITE.git"
PKG_SHORTDESC="ArtBook Next"
PKG_LONGDESC="Art Book Next - AmberELEC default theme"
PKG_TOOLCHAIN="manual"

makeinstall_target() {
    mkdir -p $INSTALL/usr/config/emulationstation/themes/$PKG_NAME
    cp -rf * $INSTALL/usr/config/emulationstation/themes/$PKG_NAME

    RESOLUTION=""
    if [[ "$DEVICE" == "RG552" ]]; then
      RESOLUTION="1920x1152"
    elif [[ "$DEVICE" == "RG351P" ]]; then
      RESOLUTION="480x320"
    elif [[ "$DEVICE" == "RG351V" || "$DEVICE" == "RG351MP" || "$DEVICE" == "RG353" ]]; then
      RESOLUTION="640x480"
    fi
    # Cleanup the directories of images not needed on device.  For non-552 devices, this saves ~100MB
    if [[ "$RESOLUTION" != "" ]]; then
      pushd $INSTALL/usr/config/emulationstation/themes/$PKG_NAME/_inc/images/systems/fullscreen || exit 1
      find . -type d -not -name "$RESOLUTION" -not -name '.' -print0 | xargs -0 -I {} rm -rf '{}'
      popd
    fi

}
