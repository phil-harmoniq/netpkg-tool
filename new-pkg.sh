#! /usr/bin/env bash

PKG_DIR=$(dirname $(readlink -f "${0}"))
echo $PKG_DIR

if [ -z "$1" ]; then
    APP_NAME="NET_App"
else
    APP_NAME=$1
fi

appimagetool $PKG_DIR/NET_Pkg.Template $HOME/Desktop/$APP_NAME
