#! /usr/bin/env bash

main_loop() {
    download_runtime
    
    echo "Extracting tar.gz into $HOME/.local/share/dotnet-runtime..."
    mkdir -p $HOME/.local/share/dotnet-runtime && tar zxf /tmp/dotnet-runtime.tar.gz -C $HOME/.local/share/dotnet-runtime 2> /dev/null

    if [ $? -eq 0 ]; then
        rm /tmp/dotnet-runtime.tar.gz;

        if ! [ -z $VER ]; then echo "Setting $HOME/.local/share/dotnet-runtime/dotnet as executable..."; fi
        chmod +x $HOME/.local/share/dotnet-runtime

        PATH_ADD='export PATH="$PATH:$HOME/.local/share/dotnet-runtime"'

        if ! (grep -qF "$PATH_ADD" $HOME/.bashrc); then
            if ! [ -z $VER ]; then echo "Adding $HOME/.local/share/dotnet-runtime to user \$PATH..."; fi
            echo "# Added by .NET Core installer" >> "$HOME/.bashrc"
            echo $PATH_ADD >> "$HOME/.bashrc"
            echo >> "$HOME/.bashrc"
        else
            if ! [ -z $VER ]; then echo "$HOME/.local/share/dotnet-runtime already detected in \$PATH; skip adding to \$PATH."; fi
        fi

        . ~/.bashrc

        echo '.NET runtime installed successfully. You will need to restart your terminal or type ". ~/.bashrc" for the changes to take effect.'
        exit 0
    else
        echo "Install failed: Error encountered while extracting dotnet-runtime."
        exit 1
    fi
}

download_runtime() {
    . /etc/os-release
    ARCH="x64"

    case "$ID" in
        "ubuntu")
            ubuntu_fetch $VERSION_ID
            return 0
            ;;
        "fedora")
            fedora_fetch $VERSION_ID
            return 0
            ;;
        *)
            echo "Install failed: $ID.$VERSION_ID is incompatible with .NET runtime."
            exit 1
            ;;
    esac
}

ubuntu_fetch() {
    echo $1
    case "$1" in
        "16.04")
            echo "Downloading .NET runtime for $ID.$VERSION_ID-x64..."
            curl -SL -o /tmp/dotnet-runtime.tar.gz https://go.microsoft.com/fwlink/?linkid=843432 2> /dev/null
            if [ $? -eq 0 ]; then return 0; fi
            ;;
        "16.10")
            echo "Downloading .NET runtime for $ID.$VERSION_ID-x64..."
            curl -SL -o /tmp/dotnet-runtime.tar.gz https://go.microsoft.com/fwlink/?linkid=843436 2> /dev/null
            if [ $? -eq 0 ]; then return 0; fi
            ;;
        "17.04")
            echo "Install failed: Ubuntu $VERSION_ID is incompatible with .NET runtime."
            exit 1
            ;;
        *)
            echo "Downloading .NET runtime for $ID.$VERSION_ID-x64..."
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
            echo "Downloading .NET runtime for $ID.$VERSION_ID-x64..."
            curl -SL -o /tmp/dotnet-runtime.tar.gz https://go.microsoft.com/fwlink/?linkid=843427 2> /dev/null
            if [ $? -eq 0 ]; then return 0; fi
            ;;
        "24")
            echo "Downloading .NET runtime for $ID.$VERSION_ID-x64..."
            curl -SL -o /tmp/dotnet-runtime.tar.gz https://go.microsoft.com/fwlink/?linkid=843431 2> /dev/null
            if [ $? -eq 0 ]; then return 0; fi
            ;;
        *)
            echo "Install failed: Fedora $VERSION_ID is incompatible with .NET runtime."
            exit 1
            ;;
    esac

    echo "Install failed: Download was not successful."
    exit 1
}

main_loop
