#! /usr/bin/env bash

export HERE=$(dirname "$(readlink -f "${0}")")
cd "$HERE"

if [[ -z "$1" ]] || [[ ! -d "$1" ]]; then
    echo "You must specify a build destination folder"
else
    if [[ ! -d "$HERE/appimagetool" ]]; then
        rm -rf "$HERE/squashfs-root" "$HERE/appimagetool.AppImage"
        wget https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage \
            -O "$HERE/appimagetool.AppImage"
        chmod a+x "$HERE/appimagetool.AppImage"
        "$HERE/appimagetool.AppImage" --appimage-extract
        mv "$HERE/squashfs-root" "$HERE/appimagetool"
        rm "$HERE/appimagetool.AppImage"
    fi
    dotnet run --project "$HERE" "$HERE" "$1"
fi
