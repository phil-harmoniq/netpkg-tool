#! /usr/bin/env bash

set -e

export HERE=$(dirname "$(readlink -f "${0}")")

if [[ "$1" == "--clean" ]]; then
    rm -r "$HERE/appimagetool"
    echo "Removed $HERE/appimagetool"
elif [[ -z "$1" ]] || [[ ! -d "$1" ]]; then
    echo "You must specify a build destination folder"
else
    if [[ ! -f "$HERE/appimagetool/AppRun" ]]; then
        rm -rf "$HERE/squashfs-root" "$HERE/appimagetool.AppImage"
        wget https://github.com/AppImage/AppImageKit/releases/download/9/appimagetool-x86_64.AppImage \
            -O "$HERE/appimagetool.AppImage"
        chmod a+x "$HERE/appimagetool.AppImage"
        "$HERE/appimagetool.AppImage" --appimage-extract
        mv "$PWD/squashfs-root" "$HERE/appimagetool"
        rm "$HERE/appimagetool.AppImage"
    fi
    dotnet run --project "$HERE" "$HERE" "$1" --noext --keep
fi
