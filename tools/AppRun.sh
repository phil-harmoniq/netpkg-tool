# If this is the first line of AppRun, new-pkg.sh didn't run properly.
# ------------------------------- Functions ------------------------------

main_loop() {
    if ! [ -z $VERB ]; then echo "AppImage auto-mounted at $HERE"; fi
    check_for_dotnet
}

check_for_dotnet() {
    check_path
    export LOC="$(which dotnet)"

    echo -n "Checking if .NET runtime is installed...";

    if [ -z "$LOC" ]; then
        say_fail
        while true; do
            read -p -n "Would you like to download & install the runtime? (y/n): " yn
            case $yn in
                [Yy]* ) start_installer; break;;
                [Nn]* ) say_fail; exit 1;;
                * ) echo "Please answer yes or no.";;
            esac
        done
    else
        say_pass
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
        echo -n ".NET detected but not in \$PATH. Adding for current session."
        export PATH=$PATH:$HOME/.local/share/dotnet/bin
        say_pass
    fi
}

start_installer() {
    $HERE/usr/bin/dotnet-installer.sh
    if [ $? -eq 0 ]; then
        start_app
    fi
}

get_colors() {
    # See if stdout is a terminal
    if [ -t 1 ]; then
        # see if it supports colors
        ncolors=$(tput colors)
        if [ -n "$ncolors" ] && [ $ncolors -ge 8 ]; then
            export bold="$(tput bold       || echo)"
            export normal="$(tput sgr0     || echo)"
            export black="$(tput setaf 0   || echo)"
            export red="$(tput setaf 1     || echo)"
            export green="$(tput setaf 2   || echo)"
            export yellow="$(tput setaf 3  || echo)"
            export blue="$(tput setaf 4    || echo)"
            export magenta="$(tput setaf 5 || echo)"
            export cyan="$(tput setaf 6    || echo)"
            export white="$(tput setaf 7   || echo)"
        fi
    fi
}


say_pass() {
    echo "${bold:-} [ ${green:-}PASS${white:-} ]${normal:-}"
}

say_fail() {
    echo "${bold:-} [ ${red:-}FAIL${white:-} ]${normal:-}"
}

# ------------------------------- Variables ------------------------------

export HERE=$(dirname $(readlink -f "${0}"))
export APPDIR=$(dirname $APPIMAGE)
export CLI_ARGS="$@"
export XDG_DATA_DIRS="$HERE/usr/share:$XDG_DATA_DIRS"
export PATH="$HERE/usr/bin:$PATH"
export PKG_LIB="$HERE/usr/lib"

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
get_colors

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
