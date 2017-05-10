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

    echo -n "Extracting tar.gz into $INSTALL_LOC"
    mkdir -p $INSTALL_LOC 2> /dev/null

    if [[ $? -eq 0 ]]; then
        tar zxf $DWNLOAD_LOC -C $INSTALL_LOC 2> /dev/null
    else
        say_fail
        echo "${red:-}Error making directory $INSTALL_LOC${normal:-}"
        exit 1
    fi

    if [[ $? -eq 0 ]]; then
        say_pass
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
        exit 0
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
    echo -n "Adding .NET to \$PATH in ~/.bashrc"
    PATH_ADD='export PATH="$HOME/.local/share/dotnet/bin:$PATH"'

    if ! (grep -qF "$PATH_ADD" $HOME/.bashrc); then
        if ! [[ -z $VERB ]]; then echo "Adding $HOME/.local/share/dotnet/bin to user \$PATH..."; fi
        echo "# Added by .NET Core installer" >> "$HOME/.bashrc"
        echo $PATH_ADD >> "$HOME/.bashrc"
        echo >> "$HOME/.bashrc"
        say_pass
    else
        say_warning
        echo "${yellow:-}$HOME/.local/share/dotnet/bin already detected in ~/.bashrc, skip adding to \$PATH.${normal:-}"
    fi
}

download_dotnet() {
    case "$OS_ID" in
        "ubuntu")
            ubuntu_fetch
            return 0
            ;;
        "fedora")
            fedora_fetch
            return 0
            ;;
        "linuxmint")
            mint_fetch
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

ubuntu_fetch() {
    case "$OS_VERSION" in
        "16.04")
            if [[ $SDK == "true" ]]; then
                echo "Downloading .NET sdk for $OS_ID.$OS_VERSION-x64..."
                curl -SL -o /tmp/dotnet-sdk.tar.gz https://go.microsoft.com/fwlink/?linkid=847089
                STATUS=$?
                download_check STATUS
            else
                echo "Downloading .NET runtime for $OS_ID.$OS_VERSION-x64..."
                curl -SL -o /tmp/dotnet-runtime.tar.gz https://go.microsoft.com/fwlink/?linkid=843432
                STATUS=$?
                download_check STATUS
            fi
            ;;
        "16.10")
            if [[ $SDK == "true" ]]; then
                echo "Downloading .NET sdk for $OS_ID.$OS_VERSION-x64..."
                curl -SL -o /tmp/dotnet-sdk.tar.gz https://go.microsoft.com/fwlink/?linkid=847090
                STATUS=$?
                download_check STATUS
            else
                echo "Downloading .NET runtime for $OS_ID.$OS_VERSION-x64..."
                curl -SL -o /tmp/dotnet-runtime.tar.gz https://go.microsoft.com/fwlink/?linkid=843436
                STATUS=$?
                download_check STATUS
            fi
            ;;
        "17.04")
            say_fail
            echo "${red:-}Ubuntu $OS_VERSION is incompatible with .NET runtime.${normal:-}"
            exit 1
            ;;
        *)
            if [[ $SDK == "true" ]]; then
                echo "Downloading .NET sdk for $OS_ID.$OS_VERSION-x64..."
                curl -SL -o /tmp/dotnet-sdk.tar.gz https://go.microsoft.com/fwlink/?linkid=847106
                STATUS=$?
                download_check STATUS
            else
                echo "Downloading .NET runtime for $OS_ID.$OS_VERSION-x64..."
                curl -SL -o /tmp/dotnet-runtime.tar.gz https://go.microsoft.com/fwlink/?linkid=843422
                STATUS=$?
                download_check STATUS
            fi
            ;;
    esac
    return 0
}

mint_fetch() {
    case "$OS_VERSION" in
        "18")
            if [[ $SDK == "true" ]]; then
                echo "Downloading .NET sdk for $OS_ID.$OS_VERSION-x64..."
                curl -SL -o /tmp/dotnet-sdk.tar.gz https://go.microsoft.com/fwlink/?linkid=847089
                STATUS=$?
                download_check STATUS
            else
                echo "Downloading .NET runtime for $OS_ID.$OS_VERSION-x64..."
                curl -SL -o /tmp/dotnet-runtime.tar.gz https://go.microsoft.com/fwlink/?linkid=843432
                STATUS=$?
                download_check STATUS
            fi
            ;;
        *)
            if [[ $SDK == "true" ]]; then
                echo "Downloading .NET sdk for $OS_ID.$OS_VERSION-x64..."
                curl -SL -o /tmp/dotnet-sdk.tar.gz https://go.microsoft.com/fwlink/?linkid=847106
                STATUS=$?
                download_check STATUS
            else
                echo "Downloading .NET runtime for $OS_ID.$OS_VERSION-x64..."
                curl -SL -o /tmp/dotnet-runtime.tar.gz https://go.microsoft.com/fwlink/?linkid=843422
                STATUS=$?
                download_check STATUS
            fi
            ;;
    esac
    return 0
}

fedora_fetch() {
    case "$OS_VERSION" in
        "23")
            if [[ $SDK == "true" ]]; then
                echo "Downloading .NET sdk for $OS_ID.$OS_VERSION-x64..."
                curl -SL -o /tmp/dotnet-sdk.tar.gz https://go.microsoft.com/fwlink/?linkid=847099
                STATUS=$?
                download_check STATUS
            else
                echo "Downloading .NET runtime for $OS_ID.$OS_VERSION-x64..."
                curl -SL -o /tmp/dotnet-runtime.tar.gz https://go.microsoft.com/fwlink/?linkid=84342
                STATUS=$?
                download_check STATUS
            fi
            ;;
        "24")
            if [[ $SDK == "true" ]]; then
                echo "Downloading .NET sdk for $OS_ID.$OS_VERSION-x64..."
                curl -SL -o /tmp/dotnet-sdk.tar.gz https://go.microsoft.com/fwlink/?linkid=847100
                STATUS=$?
                download_check STATUS
            else
                echo "Downloading .NET runtime for $OS_ID.$OS_VERSION-x64..."
                curl -SL -o /tmp/dotnet-runtime.tar.gz https://go.microsoft.com/fwlink/?linkid=843431
                STATUS=$?
                download_check STATUS
            fi
            ;;
        *)
            echo -n "Attempt to download:"
            say_fail
            echo "${red:-}Fedora $OS_VERSION is incompatible with .NET runtime.${normal:-}"
            exit 1
            ;;
    esac
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

failed_download() {
    echo -n "Attempt to download:"
    say_fail
    echo "Install failed: Download was not successful."
    exit 1
}

main_loop $1
