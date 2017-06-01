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
    echo "${green:-}NET_Pkg.Tool created at $TRGT_REL/NET_Pkg.Tool${normal:-}"
    say_bye
}

test_for_appimagetool() {
    echo -n "Checking for appimagetool..."
    appimagetool -h &> /dev/null
    if [[ $? != 0 ]]; then
        say_warning
        while true; do
            read -p "Would you like to download appimagetool?: " yn
            case $yn in
                [Yy]* )
                    get_appimagetool
                    if [[ $1 -eq 0 ]]; then return 0; else exit 1; fi
                    ;;
                [Nn]* ) echo "${red:-}User aborted the application.${normal:-}"; echo; exit 1;;
                * ) echo "Please answer yes or no.";;
            esac
        done
    else
        say_pass
        return 0
    fi
}

get_appimagetool() {
    download_appimagetool
    if [[ $1 -eq 0 ]]; then appimagetool_to_path; else exit 1; fi
}

download_appimagetool() {
    echo "Downloading appimagetool..."
    if [[ ! -d ~/.local/bin ]]; then mkdir -p ~/.local/bin ; fi
    wget https://github.com/probonopd/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage -O ~/.local/bin/appimagetool -q --show-progress
    STATUS=$?
    download_check STATUS
}

download_check() {
    if [[ $1 -eq 0 ]]; then
        echo -n "Attempt to download:"
        say_pass
        chmod +x ~/.local/bin/appimagetool
        return 0
    else
        echo -n "Attempt to downlod:"
        say_fail
        exit 1
    fi
}

appimagetool_to_path() {
    PATH_ADD='export PATH="$PATH:$HOME/.local/bin"'

    if ! (grep -qF "$PATH_ADD" $HOME/.bashrc); then
        if ! [[ -z $VERB ]]; then echo "Adding AppImageTool to \$PATH in ~/.bashrc"; fi
        echo "# Added by NET_Pkg.Tool" >> "$HOME/.bashrc"
        echo $PATH_ADD >> "$HOME/.bashrc"
        echo >> "$HOME/.bashrc"
        source ~/.bashrc
    else
        if ! [[ -z $VERB ]]; then echo "${yellow:-}$HOME/.local//bin already detected in ~/.bashrc, skip adding to \$PATH.${normal:-}"; fi
    fi
}

copy_files() {
    echo -n "Transferring files..."
    if [[ -d /tmp/.NET_Pkg.Tool ]]; then rm -rf /tmp/.NET_Pkg.Tool; fi
    cp -r $PKG_DIR /tmp/.NET_Pkg.Tool

    rm -f /tmp/.NET_Pkg.Tool/build.sh
    rm -f /tmp/.NET_Pkg.Tool/.gitignore
    rm -rf /tmp/.NET_Pkg.Tool/.git

    create_desktop_files
    mv /tmp/.NET_Pkg.Tool/tools/ToolRun.sh /tmp/.NET_Pkg.Tool/AppRun

    chmod +x /tmp/.NET_Pkg.Tool/AppRun
    chmod -R +x /tmp/.NET_Pkg.Tool/tools
    chmod -R +x /tmp/.NET_Pkg.Tool/NET_Pkg.Template/usr/bin
    say_pass
}

create_desktop_files() {
    touch /tmp/.NET_Pkg.Tool/AppIcon.png
    touch /tmp/.NET_Pkg.Tool/NET_Pkg.Tool.desktop

    echo "[Desktop Entry]" >> /tmp/.NET_Pkg.Tool/NET_Pkg.Tool.desktop
    echo >> /tmp/.NET_Pkg.Tool/NET_Pkg.Tool.desktop
    echo "Type=Application" >> /tmp/.NET_Pkg.Tool/NET_Pkg.Tool.desktop
    echo "Name=NET_Pkg.Tool" >> /tmp/.NET_Pkg.Tool/NET_Pkg.Tool.desktop
    echo "Exec=AppRun" >> /tmp/.NET_Pkg.Tool/NET_Pkg.Tool.desktop
    echo "Icon=AppIcon" >> /tmp/.NET_Pkg.Tool/NET_Pkg.Tool.desktop
    echo "Terminal=true" >> /tmp/.NET_Pkg.Tool/NET_Pkg.Tool.desktop
}

create_package() {
    if [[ -z $VERB ]]; then
        result=$(appimagetool -n /tmp/.NET_Pkg.Tool $TRGT/NET_Pkg.Tool 2>&1)
        if [[ $? -eq 0 ]]; then export complete="true"; fi
    else
        appimagetool -n /tmp/.NET_Pkg.Tool $TRGT/NET_Pkg.Tool
        if [[ $? -eq 0 ]]; then export complete="true"; fi
    fi
    echo -n "appimagetool compression:"

    if [[ $complete == "true" ]]; then
        say_pass
    else
        say_fail
        echo "${red:-}$result${normal:-}"
        exit 1
    fi
}

say_hello() {
    echo
    echo -n "-------------------- ${cyan:-}"
    echo -n "${bold:-}NET_Pkg.Tool $PKG_VERSION"
    echo "${normal:-} --------------------"
}

say_task() {
    get_trgt_relative
    echo "${cyan:-}Compile NET_Pkg source to $TRGT_REL/NET_Pkg.Tool${normal:-}"
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
source $PKG_DIR/NET_Pkg.Template/usr/bin/terminal-colors.sh
source $PKG_DIR/tools/version.info
export PKG_VERSION=$NET_PKG_VERSION

chmod -R +x $PKG_DIR/tools
chmod -R +x $PKG_DIR/NET_Pkg.Template/usr/bin

# ---------------------------- Optional Args -----------------------------

if [[ "${ARGS[1]}" == "-v" ]] || [[ "${ARGS[1]}" == "--verbose" ]]; then
    export VERB="true"
elif [[ "${ARGS[1]}" == "--nodel" ]]; then
    export NO_DEL="true"
fi

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
