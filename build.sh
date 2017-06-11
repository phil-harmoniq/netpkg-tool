#! /usr/bin/env bash

main_loop() {
    say_hello

    if [[ -z "${ARGS[0]}" ]]; then
        echo "${red:-}You must specify a target directory.${normal:-}"
        say_bye
        exit 1
    fi

    say_task

    test_for_appimagetool

    copy_files
    create_package

    if [[ -z "$NO_DEL" ]]; then
        delete_temp_files
    fi

    echo "${green:-}New netpkg-tool created at $TRGT_REL/netpkg-tool${normal:-}"
    say_bye
}

test_for_appimagetool() {
    if [[ -z $DOCKER ]]; then
        echo -n "Checking for appimagetool..."

        appimagetool -h &> /dev/null

        if [[ $? -ne 0 ]]; then

            /tmp/appimagetool -h &> /dev/null

            if [[ $? -eq 0 ]]; then
                export appimagetool_loc="/tmp/appimagetool"
                say_pass
                return 0
            fi

            say_warning
            while true; do
                if [[ -z $YES_ALL ]]; then
                    read -p "Would you like to download appimagetool?: " yn
                else
                    yn="Y"
                fi
                case $yn in
                    [Yy]* )
                        get_appimagetool
                        export appimagetool_loc="/tmp/appimagetool"
                        if [[ $? -eq 0 ]]; then return 0; else exit 1; fi
                        ;;
                    [Nn]* ) echo "${red:-}User aborted the application.${normal:-}"; echo; exit 1;;
                    * ) echo "Please answer yes or no.";;
                esac
            done
        else
            export appimagetool_loc="$(which appimagetool)"
            say_pass
            return 0
        fi
    fi
}

get_appimagetool() {
    echo -n "Downloading appimagetool..."
    curl -sSL -o /tmp/appimagetool https://github.com/probonopd/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage
    STATUS=$?
    download_check STATUS
}

download_check() {
    if [[ $1 -eq 0 ]]; then
        say_pass
        chmod +x /tmp/appimagetool
        return 0
    else
        say_fail
        exit 1
    fi
}

appimagetool_to_path() {
    PATH_ADD='export PATH="$PATH:$HOME/.local/bin"'

    if ! (grep -qF "$PATH_ADD" $HOME/.bashrc); then
        if ! [[ -z $VERB ]]; then echo "Adding AppImageTool to \$PATH in ~/.bashrc"; fi
        echo "# Added by netpkg-tool" >> "$HOME/.bashrc"
        echo $PATH_ADD >> "$HOME/.bashrc"
        echo >> "$HOME/.bashrc"
        source ~/.bashrc
    else
        if ! [[ -z $VERB ]]; then echo "${yellow:-}$HOME/.local//bin already detected in ~/.bashrc, skip adding to \$PATH.${normal:-}"; fi
    fi
}

copy_files() {
    echo -n "Transferring files..."
    rm -rf /tmp/netpkg-tool.temp
    cp -r $PKG_DIR /tmp/netpkg-tool.temp

    rm -f /tmp/netpkg-tool.temp/build.sh
    rm -f /tmp/netpkg-tool.temp/.gitignore
    rm -f /tmp/netpkg-tool.temp/.travis.yml
    rm -f /tmp/netpkg-tool.temp/netpkg-tool
    rm -rf /tmp/netpkg-tool.temp/.git
    rm -rf /tmp/netpkg-tool.temp/meta

    create_desktop_files

    # Extract appimagetool and create shortcut in $PKG_DIR/usr/bin
    if [[ -z $DOCKER ]]; then
        mkdir -p /tmp/netpkg-tool.temp/usr/share
        mkdir -p /tmp/netpkg-tool.temp/usr/bin
        cd /tmp/netpkg-tool.temp/usr/share
        cp $appimagetool_loc .
        
        result=$(./appimagetool --appimage-extract 2>&1)

        if [[ $? -ne 0 ]]; then
            say_fail
            echo "${red:-}$result${normal:-}"
        fi

        rm -f ./appimagetool
        mv ./squashfs-root ./appimagetool
        cd $PKG_DIR
    fi

    cd /tmp/netpkg-tool.temp/usr/bin
    ln -s ../share/appimagetool/AppRun appimagetool

    chmod +x /tmp/netpkg-tool.temp/AppRun
    chmod -R +x /tmp/netpkg-tool.temp/usr/bin
    say_pass
}

create_desktop_files() {
    touch /tmp/netpkg-tool.temp/AppIcon.png
    touch /tmp/netpkg-tool.temp/netpkg-tool.desktop

    echo "[Desktop Entry]" >> /tmp/netpkg-tool.temp/netpkg-tool.desktop
    echo >> /tmp/netpkg-tool.temp/netpkg-tool.desktop
    echo "Type=Application" >> /tmp/netpkg-tool.temp/netpkg-tool.desktop
    echo "Name=netpkg-tool" >> /tmp/netpkg-tool.temp/netpkg-tool.desktop
    echo "Exec=AppRun" >> /tmp/netpkg-tool.temp/netpkg-tool.desktop
    echo "Icon=AppIcon" >> /tmp/netpkg-tool.temp/netpkg-tool.desktop
    echo "Terminal=true" >> /tmp/netpkg-tool.temp/netpkg-tool.desktop
}

create_package() {
    echo -n "Compressing with appimagetool..."

    if [[ -z $VERB ]]; then
        result=$($appimagetool_loc -n /tmp/netpkg-tool.temp $TRGT/netpkg-tool 2>&1)
        if [[ $? -eq 0 ]]; then export complete="true"; fi
    else
        $appimagetool_loc -n /tmp/netpkg-tool.temp $TRGT/netpkg-tool
        if [[ $? -eq 0 ]]; then export complete="true"; fi
    fi

    if [[ $complete == "true" ]]; then
        say_pass
    else
        say_fail
        echo "${red:-}$result${normal:-}"
        exit 1
    fi
}

delete_temp_files() {
    echo -n "Deleting temporary files..."
    rm -rf /tmp/netpkg-tool.temp
    if [[ $? -eq 0 ]]; then
        say_pass
    else
        say_fail
        exit 1
    fi
}

say_hello() {
    echo
    echo -n "-------------------- ${cyan:-}"
    echo -n "${bold:-}netpkg-tool $PKG_VERSION"
    echo "${normal:-} ---------------------"
}

say_task() {
    get_trgt_relative
    echo "${cyan:-}Compile NET_Pkg source to $TRGT_REL/netpkg-tool${normal:-}"
}

say_bye() {
    echo "------------------------------------------------------------"
    echo
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

get_trgt_relative() {
    cd $TRGT
    export TRGT_REL="$(dirs -0)"
    cd $PKG_DIR
}

# ------------------------------- Variables ------------------------------

source /etc/os-release
export OS_NAME=$NAME
export OS_ID=$ID
export OS_VERSION=$VERSION_ID
export OS_CODENAME=$VERSION_CODENAME
export OS_PNAME=$PRETTY_NAME
export LOC="$(which dotnet 2> /dev/null)"
export ARGS=($@)


export PKG_DIR=$(dirname $(readlink -f "${0}"))
export TRGT=${ARGS[0]}
source $PKG_DIR/usr/bin/terminal-colors.sh
source $PKG_DIR/version.info
export PKG_VERSION=$NET_PKG_VERSION

chmod -R +x $PKG_DIR/usr/bin

# ---------------------------- Optional Args -----------------------------

for ((I=0; I <= ${#ARGS[@]}; I++)); do
    if [[ "${ARGS[$I]}" == "-v" ]] || [[ "${ARGS[$I]}" == "--verbose" ]]; then
        export VERB="true"
    elif [[ "${ARGS[$I]}" == "-k" ]] || [[ "${ARGS[$I]}" == "--keep" ]]; then
        export NO_DEL="true"
    elif [[ "${ARGS[$I]}" == "--docker-build" ]]; then
        export DOCKER="true"
    elif [[ "${ARGS[$I]}" == "--yes-all" ]]; then
        export YES_ALL="true"
    fi
done

# --------------------------- Directory Check ----------------------------

if [[ -d "$(pwd)/$TRGT" ]]; then
    export TRGT="$(readlink -m $(pwd)/$TRGT)"
else
    if ! [[ -d "$TRGT" ]]; then
        say_hello
        echo "${red:-}Error: $TRGT is not a valid directory${normal:-}"
        say_bye
        exit 1
    fi
fi

# --------------------------------- Init ---------------------------------

main_loop
