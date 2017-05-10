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

        add_to_path
        
        echo -n '.NET runtime installed:'
        say_pass
        echo 'You may need to log-out and back in or type ". ~/.profile" for the changes to take effect.'
        exit 0
    else
        echo -n '.NET runtime installed:'
        say_fail
        echo "Error encountered while extracting dotnet-runtime.tar.gz"
        exit 1
    fi
}

add_to_path() {
    PATH_ADD='export PATH="$HOME/.local/share/dotnet/bin:$PATH"'

    if ! (grep -qF "$PATH_ADD" $HOME/.profile); then
        if ! [ -z $VERB ]; then echo "Adding $HOME/.local/share/dotnet/bin to user \$PATH..."; fi
        echo "# Added by .NET Core installer" >> "$HOME/.profile"
        echo $PATH_ADD >> "$HOME/.profile"
        echo >> "$HOME/.profile"
    else
        if ! [ -z $VERB ]; then echo "$HOME/.local/share/dotnet/bin already detected in ~/.profile, skip adding to \$PATH."; fi
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
                echo "Downloading .NET sdk for $OS_ID.$OS_VERSION-x64..."
                curl -SL -o /tmp/dotnet-sdk.tar.gz https://go.microsoft.com/fwlink/?linkid=847089
                if [ $? -eq 0 ]; echo -n "Attempt to download:"; then say_pass; return 0; fi
            else
                echo "Downloading .NET runtime for $OS_ID.$OS_VERSION-x64..."
                curl -SL -o /tmp/dotnet-runtime.tar.gz https://go.microsoft.com/fwlink/?linkid=843432
                if [ $? -eq 0 ]; echo -n "Attempt to download:"; then say_pass; return 0; fi
            fi
            ;;
        "16.10")
            if [ $SDK == "true" ]; then
                echo "Downloading .NET sdk for $OS_ID.$OS_VERSION-x64..."
                curl -SL -o /tmp/dotnet-sdk.tar.gz https://go.microsoft.com/fwlink/?linkid=847090
                if [ $? -eq 0 ]; echo -n "Attempt to download:"; then say_pass; return 0; fi
            else
                echo "Downloading .NET runtime for $OS_ID.$OS_VERSION-x64..."
                curl -SL -o /tmp/dotnet-runtime.tar.gz https://go.microsoft.com/fwlink/?linkid=843436
                if [ $? -eq 0 ]; echo -n "Attempt to download:"; then say_pass; return 0; fi
            fi
            ;;
        "17.04")
            say_fail
            echo "Install failed: Ubuntu $OS_VERSION is incompatible with .NET runtime."
            exit 1
            ;;
        *)
            if [ $SDK == "true" ]; then
                echo "Downloading .NET sdk for $OS_ID.$OS_VERSION-x64..."
                curl -SL -o /tmp/dotnet-sdk.tar.gz https://go.microsoft.com/fwlink/?linkid=847106
                if [ $? -eq 0 ]; echo -n "Attempt to download:"; then say_pass; return 0; fi
            else
                echo "Downloading .NET runtime for $OS_ID.$OS_VERSION-x64..."
                curl -SL -o /tmp/dotnet-runtime.tar.gz https://go.microsoft.com/fwlink/?linkid=843422
                if [ $? -eq 0 ]; echo -n "Attempt to download:"; then say_pass; return 0; fi
            fi
            ;;
    esac
    
    echo -n "Attempt to download:"
    say_fail
    echo "Install failed: Download was not successful."
    exit 1
}

mint_fetch() {
    case "$OS_VERSION" in
        "18")
            if [ $SDK == "true" ]; then
                echo "Downloading .NET sdk for $OS_ID.$OS_VERSION-x64..."
                curl -SL -o /tmp/dotnet-sdk.tar.gz https://go.microsoft.com/fwlink/?linkid=847089
                if [ $? -eq 0 ]; echo -n "Attempt to download:"; then say_pass; return 0; fi
            else
                echo "Downloading .NET runtime for $OS_ID.$OS_VERSION-x64..."
                curl -SL -o /tmp/dotnet-runtime.tar.gz https://go.microsoft.com/fwlink/?linkid=843432
                if [ $? -eq 0 ]; echo -n "Attempt to download:"; then say_pass; return 0; fi
            fi
            ;;
        *)
            if [ $SDK == "true" ]; then
                echo "Downloading .NET sdk for $OS_ID.$OS_VERSION-x64..."
                curl -SL -o /tmp/dotnet-sdk.tar.gz https://go.microsoft.com/fwlink/?linkid=847106
                if [ $? -eq 0 ]; echo -n "Attempt to download:"; then say_pass; return 0; fi
            else
                echo "Downloading .NET runtime for $OS_ID.$OS_VERSION-x64..."
                curl -SL -o /tmp/dotnet-runtime.tar.gz https://go.microsoft.com/fwlink/?linkid=843422
                if [ $? -eq 0 ]; echo -n "Attempt to download:"; then say_pass; return 0; fi
            fi
            ;;
    esac

    echo -n "Attempt to download:"
    say_fail
    echo "Install failed: Download was not successful."
    exit 1
}

fedora_fetch() {
    case "$OS_VERSION" in
        "23")
            if [ $SDK == "true" ]; then
                echo "Downloading .NET sdk for $OS_ID.$OS_VERSION-x64..."
                curl -SL -o /tmp/dotnet-sdk.tar.gz https://go.microsoft.com/fwlink/?linkid=847099
                if [ $? -eq 0 ]; echo -n "Attempt to download:"; then say_pass; return 0; fi
            else
                echo "Downloading .NET runtime for $OS_ID.$OS_VERSION-x64..."
                curl -SL -o /tmp/dotnet-runtime.tar.gz https://go.microsoft.com/fwlink/?linkid=84342
                if [ $? -eq 0 ]; echo -n "Attempt to download:"; then say_pass; return 0; fi
            fi
            ;;
        "24")
            if [ $SDK == "true" ]; then
                echo "Downloading .NET sdk for $OS_ID.$OS_VERSION-x64..."
                curl -SL -o /tmp/dotnet-sdk.tar.gz https://go.microsoft.com/fwlink/?linkid=847100
                if [ $? -eq 0 ]; echo -n "Attempt to download:"; then say_pass; return 0; fi
            else
                echo "Downloading .NET runtime for $OS_ID.$OS_VERSION-x64..."
                curl -SL -o /tmp/dotnet-runtime.tar.gz https://go.microsoft.com/fwlink/?linkid=843431
                if [ $? -eq 0 ]; echo -n "Attempt to download:"; then say_pass; return 0; fi
            fi
            ;;
        *)
            echo -n "Attempt to download:"
            say_fail
            echo "Install failed: Fedora $OS_VERSION is incompatible with .NET runtime."
            exit 1
            ;;
    esac

    echo -n "Attempt to download:"
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
    echo "${bold:-} [ ${green:-}PASS${white:-} ] ${normal:-}"
}

say_fail() {
    echo "${bold:-} [ ${red:-}FAIL${white:-} ] ${normal:-}"
}

main_loop $1
