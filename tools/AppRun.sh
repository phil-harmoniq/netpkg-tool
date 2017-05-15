# If this is the first line of AppRun, new-pkg.sh didn't run properly.
# ------------------------------- Functions ------------------------------

main_loop() {
    if ! [[ -z $VERB ]]; then 
        say_hello
        echo "AppImage auto-mounted at $HERE"
    fi

    check_for_dotnet

    if [[ $? -eq 0 ]]; then
        if ! [[ -z $VERB ]]; then
            echo "-------------------- Program Output: --------------------"
            echo
        fi

        start_app
    fi
}

check_for_dotnet() {
    # check_path
    dotnet --version &> /dev/null

    if [[ $? -ne 0 ]]; then
        if [[ -z $VERB ]]; then echo "${yellow:-}.NET not installed.${normal:-}"; fi

        while true; do
            read -p "Would you like to download & install the .NET runtime? (y/n): " yn
            case $yn in
                [Yy]* )
                    start_installer
                    if [[ $? -eq 0 ]]; then
                        check_path
                        return 0
                    else
                        exit 1
                    fi
                    ;;
                [Nn]* ) echo "${red:-}User aborted the application.${normal:-}"; echo; exit 1;;
                * ) echo "Please answer yes or no.";;
            esac
        done
    else
        return 0
    fi
}

start_app() {
    # dotnet $HERE/usr/share/tests/arg-test.dll $ARGS
    dotnet $HERE/usr/share/app/$DLL_NAME.dll ${ARGS[@]}
    exit 0
}

check_path() {
    if ! [[ -z $VERB ]]; then echo -n "Checking if .NET runtime is installed..."; fi
    echo $PATH | grep -q  "$HOME/.local/share/dotnet/bin" 2> /dev/null
    ERR_CODE=$?

    if [[ -f "$HOME/.local/share/dotnet/bin/dotnet" ]] && [[ $ERR_CODE -ne 0 ]]; then
        if ! [[ -z $VERB ]]; then say_caution; fi
        echo "${yellow:-}.NET detected but not in \$PATH. Adding for current session.${normal:-}"
        export PATH=$HOME/.local/share/dotnet/bin:$PATH
        return 0
    elif [[ $ERR_CODE -eq 0 ]]; then
        if ! [[ -z $VERB ]]; then say_pass; fi
        return 0
    else
        if ! [[ -z $VERB ]]; then say_warning; fi
        return 1
    fi
}

start_installer() {
    $HERE/usr/bin/dotnet-installer.sh
    if [[ $? -eq 0 ]]; then
        return 0
    else
        exit 1
    fi
}

get_colors() {
    # See if stdout is a terminal
    if [[ -t 1 ]]; then
        # see if it supports colors
        ncolors=$(tput colors)
        if [[ -n "$ncolors" ]] && [[ $ncolors -ge 8 ]]; then
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

say_caution() {
    echo "${bold:-} [ ${yellow:-}PASS${white:-} ]${normal:-}"
}

say_warning() {
    echo "${bold:-} [ ${yellow:-}FAIL${white:-} ]${normal:-}"
}

say_fail() {
    echo "${bold:-} [ ${red:-}FAIL${white:-} ]${normal:-}"
}

say_hello() {
    echo
    echo -n "--------------------- ${cyan:-}"
    echo -n "${bold:-}NET_Pkg $PKG_VERSION"
    echo "${normal:-} ---------------------"
}

arg_filter() {
    params=("${ARGS[@]}")
    unset params[$1]
    set -- "${params[@]}"
    ARGS=("${params[@]}")
}

# ------------------------------- Variables ------------------------------

export HERE=$(dirname $(readlink -f "${0}"))
export APPDIR=$(dirname $APPIMAGE)
export ARGS=($@)
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
export LOC="$(which dotnet 2> /dev/null)"
get_colors

# --------------------------------- Args ---------------------------------

for I in "${!ARGS[@]}"; do
    if [[ "${ARGS[$I]}" == "--npk-v" ]] || [[ "${ARGS[$I]}" == "--npk-verbose" ]]; then
        export VERB="true"
        arg_filter $I
    elif [[ "${ARGS[$I]}" == "--npk-h" ]] || [[ "${ARGS[$I]}" == "--npk-help" ]]; then
        $HERE/usr/bin/help-menu.sh
        exit 0
    elif [[ "${ARGS[$I]}" == "--npk-d" ]] || [[ "${ARGS[$I]}" == "--npk-dir" ]]; then
        echo ".NET installed at: $LOC"
        exit 0
    fi
done

# --------------------------------- Init ---------------------------------

main_loop
