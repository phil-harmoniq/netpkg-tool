#! /usr/bin/env bash

# ------------------------------- Functions ------------------------------

main_loop() {
    say_hello

    if [[ -z "$PROJ" ]] || [[ -z "$TRGT" ]]; then
        echo "${red:-}You must specify a directory containing a *.csproj file AND a target location.${normal:-}"
        echo
        exit 1
    fi

    check_for_dotnet

    if [[ $? -eq 0 ]]; then compile_net_project; else exit 1; fi
    if [[ $? -eq 0 ]]; then transfer_files; else exit 1; fi
    if [[ $? -eq 0 ]]; then say_pass; create_pkg; else say_fail; exit 1; fi
    if [[ $? -eq 0 ]]; then
        say_pass
        if [[ -z $NO_DEL ]]; then
            delete_temp_files
        fi
    else
        say_fail
        echo ${red:-}$apptool_result${normal:-}
        echo 
        exit 1
    fi
    echo -n "Packaging complete:"
    say_pass
    if [[ -z $MAKE_SCD ]]; then
        echo "${green:-}New NET_Pkg created at $TRGT/$NEW_PKG${normal:-}"
    else
        echo "${green:-}New AppImage created at $TRGT/$NEW_PKG${normal:-}"
    fi

    say_bye
    echo
}

check_for_dotnet() {
    test_for_appimagetool
    check_for_sdk
    if [[ $? != 0 ]]; then
        install_prompt
    else
        return 0
    fi
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

appimagetool_to_path() {
    PATH_ADD='export PATH="$PATH:$HOME/.local/bin"'

    if ! (grep -qF "$PATH_ADD" $HOME/.bashrc); then
        if ! [[ -z $VERB ]]; then echo "Adding appimagetool to \$PATH in ~/.bashrc"; fi
        echo "# Added by NET_Pkg.Tool" >> "$HOME/.bashrc"
        echo $PATH_ADD >> "$HOME/.bashrc"
        echo >> "$HOME/.bashrc"
        source ~/.bashrc
    else
        if ! [[ -z $VERB ]]; then echo "${yellow:-}$HOME/.local//bin already detected in ~/.bashrc, skip adding to \$PATH.${normal:-}"; fi
    fi
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

check_for_sdk() {
    echo -n "Checking if .NET sdk is installed..."

    rm -rf /tmp/.net-sdk-test

    mkdir /tmp/.net-sdk-test && cd /tmp/.net-sdk-test
    dotnet new sln &> /dev/null

    if [[ $? -eq 0 ]]; then
        say_pass
        cd $PKG_DIR
        rm -rf /tmp/.net-sdk-test
        return 0;
    else
        say_warning
        cd $PKG_DIR
        rm -rf /tmp/.net-sdk-test
        return 1;
    fi;
}


install_prompt() {
    echo -n "Checking if necessary libraries are present"
    source $PKG_DIR/NET_Pkg.Template/usr/bin/lib-check.sh

    if [[ $libs_needed == "true" ]]; then
        say_warning
        echo "The following libraries are missing and will also need to be installed:"
        if [[ $need_unwind == "true" ]]; then echo " - libunwind"; fi
        if [[ $need_icu == "true" ]]; then echo " - libunicu"; fi
        if [[ $need_gettext == "true" ]]; then echo " - gettext"; fi
        echo "${yellow:-}It is recommended that you acquire these from your package manager, but can be locally installed.${normal:-}"
        read -p "Would you like to download & install the .NET sdk and needed libraries? (y/n): " yn
        export yn=$yn
    else
        say_pass
        read -p "Would you like to download & install the .NET sdk? (y/n): " yn
        export yn=$yn
    fi

    while true; do
        case $yn in
            [Yy]* )
                start_installer
                export just_installed="true"
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
}

start_installer() {
    if [[ $libs_needed == "true" ]]; then
        $PKG_DIR/NET_Pkg.Template/usr/bin/install-libs.sh
    fi

    $PKG_DIR/NET_Pkg.Template/usr/bin/dotnet-installer.sh -sdk
    if [[ $? -eq 0 ]]; then
        return 0
    else
        exit 1
    fi
}

compile_net_project() {
    cd $PROJ

    find_csproj
    if [[ -z $VERB ]]; then echo -n "Restoring .NET project dependencies..."; fi
    grep -qF "$HOME/.local/share/dotnet/bin" $HOME/.bashrc
    if ! [[ -z $VERB  ]] || [[ $just_installed == "true" ]]; then
        dotnet restore
    else
        restore_result=$(dotnet restore 2>&1)
    fi

    if [[ $? -eq 0 ]]; then
        if [[ -z $VERB ]]; then say_pass; fi
        if [[ -z $VERB ]]; then echo -n "Compiling .NET project..."; fi
        export CORE_VERS=$($PKG_DIR/tools/parse-csproj.py 2>&1 >/dev/null)
        if ! [[ -z $VERB ]]; then
            net_publish
        else
            publish_result=$(net_publish 2>&1)
        fi
    else
        if [[ -z $VERB ]]; then
            say_fail
            echo ${red:-}$restore_result${normal:-}
            echo
        fi
        exit 1
    fi

    if [[ $? -eq 0 ]]; then 
        if [[ -z $VERB ]]; then say_pass; fi
        cd $PKG_DIR
        return 0
    else
        if [[ -z $VERB ]]; then
            say_fail
            echo ${red:-}$publish_result${normal:-}
            echo
        fi
        exit 1
    fi
}

net_publish() {
    if [[ -z $MAKE_SCD ]]; then
        dotnet publish -f $CORE_VERS -c Release
    else
        dotnet publish -c Release -r $TARGET_OS
    fi
}

find_csproj() {
    cd $PROJ
    CSFILE=$(find . -name '*.csproj')
    LEN=${#CSFILE}
    export CSPROJ=${CSFILE:2:LEN-9}
}

transfer_files() {
    echo -n "Transferring files..."

    rm -rf /tmp/NET_Pkg.Temp

    mkdir -p /tmp/NET_Pkg.Temp
    cp -r $PKG_DIR/NET_Pkg.Template/. /tmp/NET_Pkg.Temp
    mkdir -p /tmp/NET_Pkg.Temp/usr/share/app

    if [[ -z $MAKE_SCD ]]; then
        cp -r $PROJ/bin/Release/$CORE_VERS/publish/. /tmp/NET_Pkg.Temp/usr/share/app
    else
        cp -r $PROJ/bin/Release/$CORE_VERS/$TARGET_OS/publish/. /tmp/NET_Pkg.Temp/usr/share/app
    fi

    if [[ -d "$PROJ/pkg.lib" ]]; then
        cp -r $PROJ/pkg.lib/. /tmp/NET_Pkg.Temp/usr/lib
    fi

    touch /tmp/NET_Pkg.Temp/AppRun
    echo "#! /usr/bin/env bash" >> /tmp/NET_Pkg.Temp/AppRun
    echo >> /tmp/NET_Pkg.Temp/AppRun
    echo "# -------------------------------- Config --------------------------------" >> /tmp/NET_Pkg.Temp/AppRun
    echo >> /tmp/NET_Pkg.Temp/AppRun
    echo DLL_NAME=$CSPROJ >> /tmp/NET_Pkg.Temp/AppRun
    echo PKG_VERSION=$PKG_VERSION >> /tmp/NET_Pkg.Temp/AppRun
    echo >> /tmp/NET_Pkg.Temp/AppRun

    if [[ -z $MAKE_SCD ]]; then
        cat $PKG_DIR/tools/AppRun.sh >> /tmp/NET_Pkg.Temp/AppRun
    else
        cat $PKG_DIR/tools/scd-run.sh >> /tmp/NET_Pkg.Temp/AppRun
        chmod +x /tmp/NET_Pkg.Temp/usr/share/app/$CSPROJ
    fi


    chmod +x /tmp/NET_Pkg.Temp/AppRun
    chmod -R +x /tmp/NET_Pkg.Temp/usr/bin

    rm /tmp/NET_Pkg.Temp/usr/share/app/$CSPROJ.pdb
}

create_pkg() {
    echo -n "appimagetool compression:"
    if ! [[ -z $VERB ]]; then
        run_appimagetool
    else
        apptool_result=$(run_appimagetool 2>&1)
    fi
}

run_appimagetool() {
    if [[ -z $MAKE_SCD ]]; then
        appimagetool -n /tmp/NET_Pkg.Temp $TRGT/$CSPROJ$EXTN
        export NEW_PKG="$CSPROJ$EXTN"
    else
        appimagetool -n /tmp/NET_Pkg.Temp $TRGT/$CSPROJ.AppImage
        export NEW_PKG=$CSPROJ.AppImage
    fi
}

delete_temp_files() {
    echo -n "Deleting temporary files..."
    rm -r /tmp/NET_Pkg.Temp
    if [[ $? -eq 0 ]]; then
        say_pass
    else
        exit 1
    fi
}

check_path() {
    echo $PATH | grep -q  "$HOME/.local/share/dotnet/bin" 2> /dev/null
    ERR_CODE=$?

    if [[ -f "$HOME/.local/share/dotnet/bin/dotnet" ]] && [[ $ERR_CODE -ne 0 ]]; then
        echo "${yellow:-}.NET detected but not in \$PATH. Adding for current session.${normal:-}"
        export PATH=$HOME/.local/share/dotnet/bin:$PATH
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

source /etc/os-release
export OS_NAME=$NAME
export OS_ID=$ID
export OS_VERSION=$VERSION_ID
export OS_CODENAME=$VERSION_CODENAME
export OS_PNAME=$PRETTY_NAME
export NET_LOC="$(which dotnet 2> /dev/null)"
export ARGS=($@)
export HERE=$(dirname $(readlink -f "${0}"))

if [[ -z "${LD_LIBRARY_PATH// }" ]]; then 
    export LD_LIBRARY_PATH="$HERE/usr/lib"
else
    export LD_LIBRARY_PATH="$HERE/usr/lib:$LD_LIBRARY_PATH"
fi

export PKG_DIR=$(dirname $(readlink -f "${0}"))
export PROJ=${ARGS[0]}
export TRGT=${ARGS[1]}
export EXTN=".NET"
get_colors

source $PKG_DIR/tools/version.info
export PKG_VERSION=$NET_PKG_VERSION

# ---------------------------- Critical Args -----------------------------
# Critical args will interrupt the program and quit when it is finished

if [[ -z "${ARGS[0]}" ]]; then
    $PKG_DIR/tools/pkg-tool-help.sh
    exit 0
elif [[ "${ARGS[0]}" == "-d" ]] || [[ "${ARGS[0]}" == "--dir" ]]; then
    if [[ -z "$NET_LOC" ]]; then NET="${red:-}not installed${normal:-}"
    else NET="$(dirname $NET_LOC)"; fi
    echo ".NET location: $NET"
    exit 0
elif [[ "${ARGS[0]}" == "-h" ]] || [[ "${ARGS[0]}" == "--help" ]]; then
    $PKG_DIR/tools/pkg-tool-help.sh
    exit 0
elif [[ "${ARGS[0]}" == "--install-sdk" ]]; then
    say_hello
    $PKG_DIR/NET_Pkg.Template/usr/bin/dotnet-installer.sh -sdk
    exit 0
elif [[ "${ARGS[0]}" == "--uninstall-sdk" ]]; then
    $PKG_DIR/tools/uninstaller.sh
    exit 0
fi

# ---------------------------- Optional Args -----------------------------

for ((I=0; I <= ${#ARGS[@]}; I++)); do
    if [[ "${ARGS[$I]}" == "-v" ]]; then
        export VERB="true"
        arg_filter $I
    elif [[ "${ARGS[$I]}" == "--nodel" ]]; then
        export NO_DEL="true"
        arg_filter $I
    elif [[ "${ARGS[$I]}" == "--scd" ]]; then
        if ! [[ -z "${ARGS[$I+1]}" ]]; then
            export MAKE_SCD="true"
            export TARGET_OS="${ARGS[$I+1]}"
            arg_filter $I
        else
            echo "You must specify a target OS to use the --scd flag."
            exit 1
        fi
    fi
done

# --------------------------------- Init ---------------------------------

main_loop
