# If this is the first line of AppRun, new-pkg.sh didn't run properly.
# ------------------------------- Functions ------------------------------

main_loop() {
    $APPDIR/$DLL_NAME
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

say_hello() {
    echo
    echo -n "------------------ ${cyan:-}"
    echo -n "${bold:-}NET_Pkg.Tool $PKG_VERSION"
    echo "${normal:-} -------------------"
}

say_bye() {
    echo "---------------------------------------------------------"
}

say_pass() {
    echo "${bold:-} [ ${green:-}PASS${white:-} ]${normal:-}"
}

say_warning() {
    echo "${bold:-} [ ${yellow:-}FAIL${white:-} ]${normal:-}"
}

say_fail() {
    echo "${bold:-} [ ${red:-}FAIL${white:-} ]${normal:-}"
}

arg_filter() {
    params=("${ARGS[@]}")
    unset params[$1]
    set -- "${params[@]}"
    ARGS=("${params[@]}")
}

# ------------------------------- Variables ------------------------------

export HERE=$(dirname $(readlink -f "${0}"))
export APPDIR="$HERE/usr/share/app"
export ARGS=($@)
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
