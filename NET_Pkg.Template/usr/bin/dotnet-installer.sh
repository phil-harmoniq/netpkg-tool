#! /usr/bin/env bash

main_loop() {
    if [ $1 == "-sdk" ]; then export SDK="true"; fi
    
    download_dotnet
    
    if [ $SDK == "true" ]; then
        INSTALL_LOC="$HOME/.local/share/dotnet/sdk/1.1.1"
        DWNLOAD_LOC="/tmp/dotnet-sdk.tar.gz"
    else
        INSTALL_LOC="$HOME/.local/share/dotnet/runtime/1.1.1"
        DWNLOAD_LOC="/tmp/dotnet-runtime.tar.gz"
    fi

    echo -n "Extracting tar.gz into $INSTALL_LOC"
    mkdir -p $INSTALL_LOC 2> /dev/null

    if [ $? -eq 0 ]; then
        tar zxf $DWNLOAD_LOC -C $INSTALL_LOC 2> /dev/null
    else
        say_fail
        echo "Install failed: Error making directory $INSTALL_LOC"
        exit 1
    fi

    if [ $? -eq 0 ]; then
        say_pass
        rm $DWNLOAD_LOC;

        mkdir -p $HOME/.local/share/dotnet/bin
        if [ $SDK == "true" ]; then
            ln -s $INSTALL_LOC/dotnet $HOME/.local/share/dotnet/bin/dotnet-sdk
            ln -s $HOME/.local/share/dotnet/bin/dotnet-sdk $HOME/.local/share/dotnet/bin/dotnet
            chmod +x $HOME/.local/share/dotnet/bin/dotnet-sdk
        else
            ln -s $INSTALL_LOC/dotnet $HOME/.local/share/dotnet/bin/dotnet-runtime
            ln -s $HOME/.local/share/dotnet/bin/dotnet-runtime $HOME/.local/share/dotnet/bin/dotnet
            chmod +x $HOME/.local/share/dotnet/bin/dotnet-runtime
        fi

        if ! [ -z $VERB ]; then echo "Setting $HOME/.local/share/dotnet/bin/dotnet as executable..."; fi
        chmod +x $INSTALL_LOC/dotnet
        chmod +x $HOME/.local/share/dotnet/bin/dotnet

        PATH_ADD='export PATH="$PATH:$HOME/.local/share/dotnet/bin"'

        if ! (grep -qF "$PATH_ADD" $HOME/.profile); then
            if ! [ -z $VERB ]; then echo "Adding $HOME/.local/share/dotnet/bin to user \$PATH..."; fi
            echo "# Added by .NET Core installer" >> "$HOME/.profile"
            echo $PATH_ADD >> "$HOME/.profile"
            echo >> "$HOME/.profile"
        else
            if ! [ -z $VERB ]; then echo "$HOME/.local/share/dotnet/bin already detected in ~/.profile, skip adding to \$PATH."; fi
        fi

        BASH_ADD='[[ ":$PATH:" != *":$HOME/.local/share/dotnet/bin:"* ]] && export PATH="${PATH}:$HOME/.local/share/dotnet/bin"'
         
        if ! (grep -qF "$BASH_ADD" $HOME/.bashrc); then
            if ! [ -z $VERB ]; then echo "Adding $HOME/.local/share/dotnet/bin to user ~/.bashrc..."; fi
            echo "# Added by .NET Core installer" >> "$HOME/.bashrc"
            echo $BASH_ADD >> "$HOME/.bashrc"
            echo >> "$HOME/.bashrc"
        else
            if ! [ -z $VERB ]; then echo "$HOME/.local/share/dotnet/bin already detected in ~/.bashrc, skip adding to ~/.bashrc."; fi
        fi
        
        echo -n '.NET runtime installed:'
        say_pass
        echo 'You may need to log-out and back in or type ". ~/.bashrc" for the changes to take effect.'
        exit 0
    else
        echo -n '.NET runtime installed:'
        say_fail
        echo "Error encountered while extracting dotnet-runtime.tar.gz"
        exit 1
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
            echo "Install failed: $OS_ID.$OS_VERSION is incompatible with .NET runtime."
            exit 1
            ;;
    esac
}

ubuntu_fetch() {
    case "$OS_VERSION" in
        "16.04")
            if [ $SDK == "true" ]; then
                echo -n "Downloading .NET sdk for $OS_ID.$OS_VERSION-x64..."
                curl -SL -o /tmp/dotnet-sdk.tar.gz https://go.microsoft.com/fwlink/?linkid=847089 2> /dev/null
                if [ $? -eq 0 ]; then say_pass; return 0; fi
            else
                echo -n "Downloading .NET runtime for $OS_ID.$OS_VERSION-x64..."
                curl -SL -o /tmp/dotnet-runtime.tar.gz https://go.microsoft.com/fwlink/?linkid=843432 2> /dev/null
                if [ $? -eq 0 ]; then say_pass; return 0; fi
            fi
            ;;
        "16.10")
            if [ $SDK == "true" ]; then
                echo -n "Downloading .NET sdk for $OS_ID.$OS_VERSION-x64..."
                curl -SL -o /tmp/dotnet-sdk.tar.gz https://go.microsoft.com/fwlink/?linkid=847090 2> /dev/null
                if [ $? -eq 0 ]; then say_pass; return 0; fi
            else
                echo -n "Downloading .NET runtime for $OS_ID.$OS_VERSION-x64..."
                curl -SL -o /tmp/dotnet-runtime.tar.gz https://go.microsoft.com/fwlink/?linkid=843436 2> /dev/null
                if [ $? -eq 0 ]; then say_pass; return 0; fi
            fi
            ;;
        "17.04")
            say_fail
            echo "Install failed: Ubuntu $OS_VERSION is incompatible with .NET runtime."
            exit 1
            ;;
        *)
            if [ $SDK == "true" ]; then
                echo -n "Downloading .NET sdk for $OS_ID.$OS_VERSION-x64..."
                curl -SL -o /tmp/dotnet-sdk.tar.gz https://go.microsoft.com/fwlink/?linkid=847106 2> /dev/null
                if [ $? -eq 0 ]; then say_pass; return 0; fi
            else
                echo -n "Downloading .NET runtime for $OS_ID.$OS_VERSION-x64..."
                curl -SL -o /tmp/dotnet-runtime.tar.gz https://go.microsoft.com/fwlink/?linkid=843422 2> /dev/null
                if [ $? -eq 0 ]; then say_pass; return 0; fi
            fi
            ;;
    esac
    say_fail
    echo "Install failed: Download was not successful."
    exit 1
}

mint_fetch() {
    case "$OS_VERSION" in
        "18")
            if [ $SDK == "true" ]; then
                echo -n "Downloading .NET sdk for $OS_ID.$OS_VERSION-x64..."
                curl -SL -o /tmp/dotnet-sdk.tar.gz https://go.microsoft.com/fwlink/?linkid=847089 2> /dev/null
                if [ $? -eq 0 ]; then say_pass; return 0; fi
            else
                echo -n "Downloading .NET runtime for $OS_ID.$OS_VERSION-x64..."
                curl -SL -o /tmp/dotnet-runtime.tar.gz https://go.microsoft.com/fwlink/?linkid=843432 2> /dev/null
                if [ $? -eq 0 ]; then say_pass; return 0; fi
            fi
            ;;
        *)
            if [ $SDK == "true" ]; then
                echo -n "Downloading .NET sdk for $OS_ID.$OS_VERSION-x64..."
                curl -SL -o /tmp/dotnet-sdk.tar.gz https://go.microsoft.com/fwlink/?linkid=847106 2> /dev/null
                if [ $? -eq 0 ]; then say_pass; return 0; fi
            else
                echo -n "Downloading .NET runtime for $OS_ID.$OS_VERSION-x64..."
                curl -SL -o /tmp/dotnet-runtime.tar.gz https://go.microsoft.com/fwlink/?linkid=843422 2> /dev/null
                if [ $? -eq 0 ]; then say_pass; return 0; fi
            fi
            ;;
    esac

    say_fail
    echo "Install failed: Download was not successful."
    exit 1
}

fedora_fetch() {
    case "$OS_VERSION" in
        "23")
            if [ $SDK == "true" ]; then
                echo -n "Downloading .NET sdk for $OS_ID.$OS_VERSION-x64..."
                curl -SL -o /tmp/dotnet-sdk.tar.gz https://go.microsoft.com/fwlink/?linkid=847099 2> /dev/null
                if [ $? -eq 0 ]; then say_pass; return 0; fi
            else
                echo -n "Downloading .NET runtime for $OS_ID.$OS_VERSION-x64..."
                curl -SL -o /tmp/dotnet-runtime.tar.gz https://go.microsoft.com/fwlink/?linkid=843427 2> /dev/null
                if [ $? -eq 0 ]; then say_pass; return 0; fi
            fi
            ;;
        "24")
            if [ $SDK == "true" ]; then
                echo -n "Downloading .NET sdk for $OS_ID.$OS_VERSION-x64..."
                curl -SL -o /tmp/dotnet-sdk.tar.gz https://go.microsoft.com/fwlink/?linkid=847100 2> /dev/null
                if [ $? -eq 0 ]; then say_pass; return 0; fi
            else
                echo -n "Downloading .NET runtime for $OS_ID.$OS_VERSION-x64..."
                curl -SL -o /tmp/dotnet-runtime.tar.gz https://go.microsoft.com/fwlink/?linkid=843431 2> /dev/null
                if [ $? -eq 0 ]; then say_pass; return 0; fi
            fi
            ;;
        *)
            say_fail
            echo "Install failed: Fedora $OS_VERSION is incompatible with .NET runtime."
            exit 1
            ;;
    esac

    say_fail
    echo "Install failed: Download was not successful."
    exit 1
}

get_colors() {
    # Setup some colors to use. These need to work in fairly limited shells, like the Ubuntu Docker container where there are only 8 colors.
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
    echo " ${bold:-} [ ${green:-}PASS${white:-} ] ${normal:-}"
}

say_fail() {
    echo " ${bold:-} [ ${red:-}FAIL${white:-} ] ${normal:-}"
}

main_loop $1
