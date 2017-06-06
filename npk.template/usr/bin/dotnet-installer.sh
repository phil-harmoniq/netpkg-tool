#! /usr/bin/env bash

main_loop() {
    if [[ $1 == "-sdk" ]]; then export SDK="true"; fi
    
    download_dotnet
    
    if [[ $SDK == "true" ]]; then
        INSTALL_LOC="$HOME/.local/share/dotnet/sdk/1.1.1"
        DWNLOAD_LOC="/tmp/dotnet-sdk.tar.gz"
    else
        INSTALL_LOC="$HOME/.local/share/dotnet/runtime/1.1.1"
        DWNLOAD_LOC="/tmp/dotnet-runtime.tar.gz"
    fi

    if ! [[ -z $VERB ]]; then echo "Extracting tar.gz into $INSTALL_LOC"; fi
    mkdir -p $INSTALL_LOC 2> /dev/null

    if [[ $? -eq 0 ]]; then
        tar zxf $DWNLOAD_LOC -C $INSTALL_LOC 2> /dev/null
    else
        say_fail
        echo "${red:-}Error making directory $INSTALL_LOC${normal:-}"
        exit 1
    fi

    if [[ $? -eq 0 ]]; then
        rm $DWNLOAD_LOC;

        mkdir -p $HOME/.local/share/dotnet/bin
        if [[ -f $HOME/.local/share/dotnet/bin/dotnet ]]; then rm $HOME/.local/share/dotnet/bin/dotnet; fi

        if [[ $SDK == "true" ]]; then
            if [[ -f $HOME/.local/share/dotnet/bin/dotnet-sdk ]]; then rm $HOME/.local/share/dotnet/bin/dotnet-sdk; fi
            ln -s $INSTALL_LOC/dotnet $HOME/.local/share/dotnet/bin/dotnet-sdk
            ln -s $HOME/.local/share/dotnet/bin/dotnet-sdk $HOME/.local/share/dotnet/bin/dotnet
            chmod +x $HOME/.local/share/dotnet/bin/dotnet-sdk
        else
            if [[ -f $HOME/.local/share/dotnet/bin/dotnet-runtime ]]; then rm $HOME/.local/share/dotnet/bin/dotnet-runtime; fi
            ln -s $INSTALL_LOC/dotnet $HOME/.local/share/dotnet/bin/dotnet-runtime
            ln -s $HOME/.local/share/dotnet/bin/dotnet-runtime $HOME/.local/share/dotnet/bin/dotnet
            chmod +x $HOME/.local/share/dotnet/bin/dotnet-runtime
        fi

        if ! [[ -z $VERB ]]; then echo "Setting $HOME/.local/share/dotnet/bin/dotnet as executable..."; fi
        chmod +x $INSTALL_LOC/dotnet
        chmod +x $HOME/.local/share/dotnet/bin/dotnet

        add_to_path
        
        if [[ $SDK == "true" ]]; then echo -n '.NET sdk install:'
        else echo -n '.NET runtime install:'; fi
        say_pass
        echo 'You may need to log-out and back in or type ". ~/.bashrc" for the changes to take effect.'
        return 0
    else
        if [[ $SDK == "true" ]]; then echo -n '.NET sdk install:'
        else echo -n '.NET runtime install:'; fi
        say_fail
        if [[ $SDK == "true" ]]; then echo -n "${red:-}Error encountered while extracting dotnet-sdk.tar.gz${normal:-}"
        else echo "${red:-}Error encountered while extracting dotnet-runtime.tar.gz${normal:-}"; fi
        exit 1
    fi
}

add_to_path() {
    PATH_ADD='export PATH="$HOME/.local/share/dotnet/bin:$PATH"'

    if ! (grep -qF "$PATH_ADD" $HOME/.bashrc); then
        if ! [[ -z $VERB ]]; then echo "Adding .NET to \$PATH in ~/.bashrc"; fi
        echo "# Added by .NET Core installer" >> "$HOME/.bashrc"
        echo $PATH_ADD >> "$HOME/.bashrc"
        echo >> "$HOME/.bashrc"
    else
        echo "${yellow:-}$HOME/.local/share/dotnet/bin already detected in ~/.bashrc, skip adding to \$PATH.${normal:-}"
    fi
}

download_dotnet() {
    case "$OS_ID" in
        "debian")
            debian_fetch
            return 0
            ;;
        "ubuntu")
            ubuntu_fetch
            return 0
            ;;
        "linuxmint")
            mint_fetch
            return 0
            ;;
        "fedora")
            fedora_fetch
            return 0
            ;;
        "centos")
            centos_fetch
            return 0
            ;;
        "opensuse")
            suse_fetch
            return 0
            ;;
        *)
            echo -n "Attempt to download:"
            say_fail
            echo "${red:-}$OS_ID.$OS_VERSION is incompatible with .NET runtime.${normal:-}"
            exit 1
            ;;
    esac
}

debian_fetch() {
    if (($OS_VERSION < 8)); then
        say_incompatible
    else
        get_type
    fi
    return 0
}

ubuntu_fetch() {
    LOWEST="14.04"
    VALID=$($INSTALLER_LOC/valid-version.py $OS_VERSION $LOWEST 2>&1)
    
    if [[ $VALID == "true" ]]; then
        get_type
    else
        say_incompatible
    fi
    return 0
}

mint_fetch() {
    LOWEST="17.0"
    VALID=$($INSTALLER_LOC/valid-version.py $OS_VERSION $LOWEST 2>&1)

    if [[ $VALID == "true" ]]; then
        get_type
    else
        say_incompatible
    fi
    return 0
}

fedora_fetch() {
    if (($OS_VERSION < 25)); then
        say_incompatible
    else
        get_type
    fi
    return 0
}

centos_fetch() {
    if (($OS_VERSION < 7)); then
        say_incompatible
    else
        get_type
    fi
    return 0
}

suse_fetch() {
    LOWEST="42.2"
    VALID=$($INSTALLER_LOC/valid-version.py $OS_VERSION $LOWEST 2>&1)

    if [[ $VALID == "true" ]]; then
        get_type
    else
        say_incompatible
    fi
    return 0
}

get_colors() {
    # Setup some colors to use. These need to work in fairly limited shells, like the Ubuntu Docker container where there are only 8 colors.
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

get_type() {
    if [[ $SDK == "true" ]]; then
        wget_sdk
    else
        wget_runtime
    fi
}

wget_sdk() {
    echo "Downloading .NET sdk for $OS_ID.$OS_VERSION-x64..."
    wget https://download.microsoft.com/download/0/6/5/0656B047-5F2F-4281-A851-F30776F8616D/dotnet-dev-linux-x64.2.0.0-preview1-005977.tar.gz -O /tmp/dotnet-sdk.tar.gz -q --show-progress
    STATUS=$?
    download_check STATUS
}

wget_runtime() {
    echo "Downloading .NET runtime for $OS_ID.$OS_VERSION-x64..."
    wget https://download.microsoft.com/download/0/9/0/09060200-E749-4025-A51A-83391C611C86/dotnet-linux-x64.2.0.0-preview1-002111-00.tar.gz -O /tmp/dotnet-runtime.tar.gz -q --show-progress
    STATUS=$?
    download_check STATUS
}

say_pass() {
    echo "${bold:-} [ ${green:-}PASS${white:-} ] ${normal:-}"
}

say_fail() {
    echo "${bold:-} [ ${red:-}FAIL${white:-} ] ${normal:-}"
}

download_check() {
    if [[ $1 -eq 0 ]]; then
        echo -n "Attempt to download:"
        say_pass
        return 0
    else
        echo -n "Attempt to downlod:"
        say_fail
        echo "${red:-}Install failed: Download was not successful.${normal:-}"
        exit 1
    fi
}

say_incompatible() {
    echo -n "Attempt to download:"
    say_fail
    echo "${red:-}$OS_ID.$OS_VERSION is incompatible with .NET runtime.${normal:-}"
    exit 1
}

export INSTALLER_LOC=$(dirname $(readlink -f "${0}"))

main_loop $1
