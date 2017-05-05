#! /usr/bin/env bash

main_loop() {
    download_runtime
    
    echo "Extracting tar.gz into $HOME/.local/share/dotnet-runtime..."
    mkdir -p $HOME/.local/share/dotnet-runtime && tar zxf /tmp/dotnet-runtime.tar.gz -C $HOME/.local/share/dotnet-runtime 2> /dev/null

    if [ $? -eq 0 ]; then
        rm /tmp/dotnet-runtime.tar.gz;

        if ! [ -z $VER ]; then echo "Setting $HOME/.local/share/dotnet-runtime/dotnet as executable..."; fi
        chmod +x $HOME/.local/share/dotnet-runtime

        PATH_ADD='if [ -d "$HOME/.local/share/dotnet-runtime" ] ; then PATH="$HOME/bin:$PATH" fi'

        if ! (grep -qF "$PATH_ADD" $HOME/.profile); then
            if ! [ -z $VER ]; then echo "Adding $HOME/.local/share/dotnet-runtime to user \$PATH..."; fi
            echo "# Added by .NET Core installer" >> "$HOME/.profile"
            echo $PATH_ADD >> "$HOME/.profile"
            echo >> "$HOME/.profile"
        else
            if ! [ -z $VER ]; then echo "$HOME/.local/share/dotnet-runtime already detected in \$PATH, skip adding to \$PATH."; fi
        fi

        . ~/.profile

        echo '.NET runtime installed successfully. You will need to restart your terminal or type ". ~/.profile" for the changes to take effect.'
        exit 0
    else
        echo "Install failed: Error encountered while extracting dotnet-runtime."
        exit 1
    fi
}

download_runtime() {
    case "$OS_ID" in
        "ubuntu")
            ubuntu_fetch $OS_VERSION
            return 0
            ;;
        "fedora")
            fedora_fetch $OS_VERSION
            return 0
            ;;
        *)
            echo "Install failed: $OS_ID.$OS_VERSION is incompatible with .NET runtime."
            exit 1
            ;;
    esac
}

ubuntu_fetch() {
    echo $1
    case "$1" in
        "16.04")
            echo "Downloading .NET runtime for $OS_ID.$OS_VERSION-x64..."
            curl -SL -o /tmp/dotnet-runtime.tar.gz https://go.microsoft.com/fwlink/?linkid=843432 2> /dev/null
            if [ $? -eq 0 ]; then return 0; fi
            ;;
        "16.10")
            echo "Downloading .NET runtime for $OS_ID.$OS_VERSION-x64..."
            curl -SL -o /tmp/dotnet-runtime.tar.gz https://go.microsoft.com/fwlink/?linkid=843436 2> /dev/null
            if [ $? -eq 0 ]; then return 0; fi
            ;;
        "17.04")
            echo "Install failed: Ubuntu $OS_VERSION is incompatible with .NET runtime."
            exit 1
            ;;
        *)
            echo "Downloading .NET runtime for $OS_ID.$OS_VERSION-x64..."
            curl -SL -o /tmp/dotnet-runtime.tar.gz https://go.microsoft.com/fwlink/?linkid=843422 2> /dev/null
            if [ $? -eq 0 ]; then return 0; fi
            ;;
    esac

    echo "Install failed: Download was not successful."
    exit 1
}

fedora_fetch() {
    echo $1
    case "$1" in
        "23")
            echo "Downloading .NET runtime for $OS_ID.$OS_VERSION-x64..."
            curl -SL -o /tmp/dotnet-runtime.tar.gz https://go.microsoft.com/fwlink/?linkid=843427 2> /dev/null
            if [ $? -eq 0 ]; then return 0; fi
            ;;
        "24")
            echo "Downloading .NET runtime for $OS_ID.$OS_VERSION-x64..."
            curl -SL -o /tmp/dotnet-runtime.tar.gz https://go.microsoft.com/fwlink/?linkid=843431 2> /dev/null
            if [ $? -eq 0 ]; then return 0; fi
            ;;
        *)
            echo "Install failed: Fedora $OS_VERSION is incompatible with .NET runtime."
            exit 1
            ;;
    esac

    echo "Install failed: Download was not successful."
    exit 1
}

main_loop
