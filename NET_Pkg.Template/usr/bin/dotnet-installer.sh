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

        if ! (grep -qF "$PATH_ADD" $HOME/.profile); then
            if ! [ -z $VER ]; then echo "Adding $HOME/.local/share/dotnet-runtime to user \$PATH..."; fi
            echo "# Added by .NET Core installer" >> "$HOME/.profile"
            echo $PATH_ADD >> "$HOME/.profile"
            echo >> "$HOME/.profile"
        else
            if ! [ -z $VER ]; then echo "$HOME/.local/share/dotnet-runtime already detected in \$PATH, skip adding to \$PATH."; fi
        fi

        echo '.NET runtime installed successfully. You will need to restart your terminal or log-out and back in for the changes to take effect.'
        exit 0
    else
        echo "Install failed: Error encountered while extracting dotnet-runtime."
        exit 1
    fi
}

download_runtime() {
    source /etc/os-release
    export OS_NAME=$NAME
    export OS_ID=$ID
    export OS_VERSION=$VERSION_ID
    export OS_CODENAME=$VERSION_CODENAME
    export OS_PNAME=$PRETTY_NAME

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
    case "$1" in
        "16.04")
            echo "Downloading .NET runtime for $OS_ID.$OS_VERSION-x64..."
            curl -SL -o /tmp/dotnet-runtime.tar.gz https://dotnetcli.blob.core.windows.net/dotnet/release/1.1.0/Binaries/Latest/dotnet-ubuntu.16.04-x64.latest.tar.gz 2> /dev/null
            if [ $? -eq 0 ]; then return 0; fi
            ;;
        "16.10")
            echo "Downloading .NET runtime for $OS_ID.$OS_VERSION-x64..."
            curl -SL -o /tmp/dotnet-runtime.tar.gz https://dotnetcli.blob.core.windows.net/dotnet/release/1.1.0/Binaries/Latest/dotnet-ubuntu.16.10-x64.latest.tar.gz 2> /dev/null
            if [ $? -eq 0 ]; then return 0; fi
            ;;
        "17.04")
            echo "Install failed: Ubuntu $OS_VERSION is incompatible with .NET runtime."
            exit 1
            ;;
        *)
            echo "Downloading .NET runtime for $OS_ID.$OS_VERSION-x64..."
            curl -SL -o /tmp/dotnet-runtime.tar.gz https://dotnetcli.blob.core.windows.net/dotnet/release/1.1.0/Binaries/Latest/dotnet-ubuntu-x64.latest.tar.gz 2> /dev/null
            if [ $? -eq 0 ]; then return 0; fi
            ;;
    esac

    echo "Install failed: Download was not successful."
    exit 1
}

fedora_fetch() {
    case "$1" in
        "23")
            echo "Downloading .NET runtime for $OS_ID.$OS_VERSION-x64..."
            curl -SL -o /tmp/dotnet-runtime.tar.gz https://dotnetcli.blob.core.windows.net/dotnet/release/1.1.0/Binaries/Latest/dotnet-fedora.23-x64.latest.tar.gz 2> /dev/null
            if [ $? -eq 0 ]; then return 0; fi
            ;;
        "24")
            echo "Downloading .NET runtime for $OS_ID.$OS_VERSION-x64..."
            curl -SL -o /tmp/dotnet-runtime.tar.gz https://dotnetcli.blob.core.windows.net/dotnet/release/1.1.0/Binaries/Latest/dotnet-fedora.24-x64.latest.tar.gz 2> /dev/null
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
