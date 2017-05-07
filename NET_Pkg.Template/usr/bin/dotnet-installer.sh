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

    echo "Extracting tar.gz into $INSTALL_LOC"
    mkdir -p $INSTALL_LOC 2> /dev/null

    if [ $? -eq 0 ]; then
        tar zxf $DWNLOAD_LOC -C $INSTALL_LOC 2> /dev/null
    else
        echo "Install failed: Error making directory $INSTALL_LOC"
        exit 1
    fi

    if [ $? -eq 0 ]; then
        rm $DWNLOAD_LOC;

        mkdir -p $HOME/.local/share/dotnet/bin
        ln -s $INSTALL_LOC/dotnet $HOME/.local/share/dotnet/bin/dotnet

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
        
        echo '.NET runtime installed successfully. You may need to log-out and back in or type ". ~/.profile" for the changes to take effect.'
        exit 0
    else
        echo "Install failed: Error encountered while extracting dotnet-runtime.tar.gz"
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
        *)
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
                curl -SL -o /tmp/dotnet-sdk.tar.gz https://go.microsoft.com/fwlink/?linkid=847089 2> /dev/null
                if [ $? -eq 0 ]; then return 0; fi
            else
                echo "Downloading .NET runtime for $OS_ID.$OS_VERSION-x64..."
                curl -SL -o /tmp/dotnet-runtime.tar.gz https://go.microsoft.com/fwlink/?linkid=843432 2> /dev/null
                if [ $? -eq 0 ]; then return 0; fi
            fi
            ;;
        "16.10")
            if [ $SDK == "true" ]; then
                echo "Downloading .NET sdk for $OS_ID.$OS_VERSION-x64..."
                curl -SL -o /tmp/dotnet-sdk.tar.gz https://go.microsoft.com/fwlink/?linkid=847090 2> /dev/null
                if [ $? -eq 0 ]; then return 0; fi
            else
                echo "Downloading .NET runtime for $OS_ID.$OS_VERSION-x64..."
                curl -SL -o /tmp/dotnet-runtime.tar.gz https://go.microsoft.com/fwlink/?linkid=843436 2> /dev/null
                if [ $? -eq 0 ]; then return 0; fi
            fi
            ;;
        "17.04")
            echo "Install failed: Ubuntu $OS_VERSION is incompatible with .NET runtime."
            exit 1
            ;;
        *)
            if [ $SDK == "true" ]; then
                echo "Downloading .NET sdk for $OS_ID.$OS_VERSION-x64..."
                curl -SL -o /tmp/dotnet-sdk.tar.gz https://go.microsoft.com/fwlink/?linkid=847106 2> /dev/null
                if [ $? -eq 0 ]; then return 0; fi
            else
                echo "Downloading .NET runtime for $OS_ID.$OS_VERSION-x64..."
                curl -SL -o /tmp/dotnet-runtime.tar.gz https://go.microsoft.com/fwlink/?linkid=843422 2> /dev/null
                if [ $? -eq 0 ]; then return 0; fi
            fi
            ;;
    esac

    echo "Install failed: Download was not successful."
    exit 1
}

fedora_fetch() {
    case "$OS_VERSION" in
        "23")
            if [ $SDK == "true" ]; then
                echo "Downloading .NET sdk for $OS_ID.$OS_VERSION-x64..."
                curl -SL -o /tmp/dotnet-sdk.tar.gz https://go.microsoft.com/fwlink/?linkid=847099 2> /dev/null
                if [ $? -eq 0 ]; then return 0; fi
            else
                echo "Downloading .NET runtime for $OS_ID.$OS_VERSION-x64..."
                curl -SL -o /tmp/dotnet-runtime.tar.gz https://go.microsoft.com/fwlink/?linkid=843427 2> /dev/null
                if [ $? -eq 0 ]; then return 0; fi
            fi
            ;;
        "24")
            if [ $SDK == "true" ]; then
                echo "Downloading .NET sdk for $OS_ID.$OS_VERSION-x64..."
                curl -SL -o /tmp/dotnet-sdk.tar.gz https://go.microsoft.com/fwlink/?linkid=847100 2> /dev/null
                if [ $? -eq 0 ]; then return 0; fi
            else
                echo "Downloading .NET runtime for $OS_ID.$OS_VERSION-x64..."
                curl -SL -o /tmp/dotnet-runtime.tar.gz https://go.microsoft.com/fwlink/?linkid=843431 2> /dev/null
                if [ $? -eq 0 ]; then return 0; fi
            fi
            ;;
        *)
            echo "Install failed: Fedora $OS_VERSION is incompatible with .NET runtime."
            exit 1
            ;;
    esac

    echo "Install failed: Download was not successful."
    exit 1
}

main_loop $1
