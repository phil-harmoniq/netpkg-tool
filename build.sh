#! /usr/bin/env bash

main_loop() {
    say_hello

    if [[ -z "$TRGT" ]]; then
        echo "${red:-}You must specify a target directory.${normal:-}"
        exit 1
    fi

    test_for_appimagetool

    copy_files
    create_package
    echo "${green:-}New NET_Pkg created at $TRGT/$CSPROJ$EXTN${normal:-}"
    say_bye
}

test_for_appimagetool() {
    echo -n "Checking for AppImageToolkit..."
    appimagetool -h &> /dev/null
    if [[ $? != 0 ]]; then
        say_warning
        while true; do
            read -p "Would you like to download AppImageToolkit?: " yn
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
    echo "Downloading AppImageToolkit..."
    if [[ ! -d ~/.local/bin ]]; then mkdir -p ~/.local/bin ; fi
    curl -SL -o ~/.local/bin/appimagetool https://github.com/probonopd/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage
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
        appimagetool -n /tmp/.NET_Pkg.Tool $TRGT/NET_Pkg.Tool &> /dev/null
        if [[ $? -eq 0 ]]; then export complete="true"; fi
    else
        appimagetool -n /tmp/.NET_Pkg.Tool $TRGT/NET_Pkg.Tool
        if [[ $? -eq 0 ]]; then export complete="true"; fi
    fi
    echo -n "AppImageTool compression:"

    if [[ complete == "true" ]]; then
        say_pass
    else
        say_fail
        exit 1
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

if [[ "${ARGS[2]}" == "-v" ]] || [[ "${ARGS[0]}" == "--verbose" ]]; then
    export VERB="true"
elif [[ "${ARGS[2]}" == "--nodel" ]]; then
    export NO_DEL="true"
fi

# --------------------------------- Init ---------------------------------

main_loop
