#! /usr/bin/env bash

main_loop() {
    if [ -z "$PROJ" ] || [ -z "$TRGT" ]; then
        echo "You must specify a directory containing a *.csproj file AND a target location."
        exit 1
    #else [ ! -f "$PROJ/*.csproj" ]; then
    #    echo "*.csproj not detected in directory."
    #    exit 1
    fi

    check_for_dotnet

    if [ $? -eq 0 ]; then compile_net_project; fi
    if [ $? -eq 0 ]; then transfer_files; fi
    if [ $? -eq 0 ]; then create_pkg; fi
    delete_temp_files
}

check_for_dotnet() {
    export LOC="$(which dotnet)"

    if [ -z "$LOC" ]; then
        echo ".NET sdk not detected, attempting new install..."
        $PKG_DIR/NET_Pkg.Template/usr/bin/dotnet-installer.sh -sdk
        if [ $? -eq 0 ]; then
            check_path
            return 0
        fi
    else
        echo ".NET sdk detected at $LOC, installer not required.";
        return 0
    fi

    echo ".NET sdk install failed"
    exit 1
}

compile_net_project() {
    cd $PROJ

    dotnet restore

    if [ $? -eq 0 ]; then 
        dotnet publish -f netcoreapp1.1 -c Release
    else
        echo "Failed to restore .NET Core application dependencies."
        exit 1
    fi

    if [ $? -eq 0 ]; then 
        cd $PKG_DIR
        return 0
    else
        echo "Failed to complile .NET Core application."
        exit 1
    fi
}

transfer_files() {
    mkdir -p $PKG_DIR/NET_Pkg.Template/usr/share/app
    cp -r $PROJ/bin/Release/netcoreapp1.1/publish/. $PKG_DIR/NET_Pkg.Template/usr/share/app
}

create_pkg() {
    if [ -z "$1" ]; then
        APP_NAME="App"
    else
        APP_NAME=$1
    fi

    appimagetool $PKG_DIR/NET_Pkg.Template $TRGT/$APP_NAME".NET"
}

delete_temp_files() {
    rm -r $PKG_DIR/NET_Pkg.Template/usr/share/app
}

check_path() {
    echo $PATH | grep -q  "$HOME/.local/share/dotnet/bin" 2> /dev/null
    ERR_CODE=$?

    if [ -f "$HOME/.local/share/dotnet/bin/dotnet" ] && [ $ERR_CODE -ne 0 ]; then
        echo ".NET detected but not in \$PATH. Adding for current session."
        export PATH=$PATH:$HOME/.local/share/dotnet/bin
    fi
}

source /etc/os-release
export OS_NAME=$NAME
export OS_ID=$ID
export OS_VERSION=$VERSION_ID
export OS_CODENAME=$VERSION_CODENAME
export OS_PNAME=$PRETTY_NAME

export PKG_DIR=$(dirname $(readlink -f "${0}"))
export PROJ=$1
export TRGT=$2

main_loop
