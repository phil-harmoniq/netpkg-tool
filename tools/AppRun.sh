# If this is the first line of AppRun, new-pkg.sh didn't run properly.
# ------------------------------- Functions ------------------------------

main_loop() {
    if ! [ -z $VERB ]; then echo "AppImage auto-mounted at $HERE"; fi
    check_for_dotnet
}

check_for_dotnet() {
    check_path
    export LOC="$(which dotnet)"

    if [ -z "$LOC" ]; then
        echo
        echo "-------------------- .NET_Pkg $PKG_VERSION --------------------"
        echo "  Warning: .NET not detected on this system."
        while true; do
            read -p "  Would you like to download & install the runtime? (yes/no): " yn
            case $yn in
                [Yy]* ) start_installer; break;;
                [Nn]* ) exit 1;;
                * ) echo "Please answer yes or no.";;
            esac
        done
    else
        if ! [ -z $VERB ]; then
            echo ".NET runtime detected at $LOC, installer not required.";
        fi
        start_app
    fi
}

start_app() {
    check_path
    # dotnet $HERE/usr/share/tests/arg-test.dll $CLI_ARGS
    dotnet $HERE/usr/share/app/$DLL_NAME.dll $CLI_ARGS
    exit 0
}

check_path() {
    echo $PATH | grep -q  "$HOME/.local/share/dotnet/bin" 2> /dev/null
    ERR_CODE=$?

    if [ -f "$HOME/.local/share/dotnet/bin/dotnet" ] && [ $ERR_CODE -ne 0 ]; then
        echo ".NET detected but not in \$PATH. Adding for current session."
        export PATH=$PATH:$HOME/.local/share/dotnet/bin
    fi
}

start_installer() {
    $HERE/usr/bin/dotnet-installer.sh 2> /dev/null
    if [ $? -eq 0 ]; then
        start_app
    fi
}

# ------------------------------- Variables ------------------------------

export HERE=$(dirname $(readlink -f "${0}"))
export CLI_ARGS="$@"
export XDG_DATA_DIRS="$HERE/usr/share:$XDG_DATA_DIRS"
export PATH="$HERE/usr/bin:$PATH"
if [[ -z "${LD_LIBRARY_PATH// }" ]]; then 
    export LD_LIBRARY_PATH="$HERE/usr/lib"
else
    export LD_LIBRARY_PATH="$HERE/usr/lib:$LD_LIBRARY_PATH"
fi

source /etc/os-release
export OS_NAME=$NAME
export OS_ID=$ID
export OS_VERSION=$VERSION_ID
export OS_CODENAME=$VERSION_CODENAME
export OS_PNAME=$PRETTY_NAME

export PKG_VERSION=$PKG_VERSION
export DLL_NAME=$DLL_NAME

# --------------------------------- Args ---------------------------------

if [ "$1" == "--netpkg-v" ] || [ "$1" == "--netpkg-verbose" ]; then
    VERB="true";
    export VERB=$VERB
elif [ "$1" == "--netpkg-h" ] || [ "$1" == "--netpkg-help" ]; then
    $HERE/usr/bin/help-menu.sh
    exit 0
elif [ "$1" == "--netpkg-d" ] || [ "$1" == "--netpkg-dir" ]; then
    echo ".NET installed at: $LOC"
    exit 0
fi

# --------------------------------- Init ---------------------------------

main_loop