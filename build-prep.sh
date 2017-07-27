#! /usr/bin/env bash

export HERE=$(dirname "$(readlink -f "${0}")")
rm -rf $HERE/squashfs-root $HERE/appimagetool.AppImage
wget https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage -O $HERE/appimagetool.AppImage
chmod a+x $HERE/appimagetool.AppImage
$HERE/appimagetool.AppImage --appimage-extract
mv $HERE/squashfs-root $HERE/appimagetool
rm $HERE/appimagetool.AppImage
