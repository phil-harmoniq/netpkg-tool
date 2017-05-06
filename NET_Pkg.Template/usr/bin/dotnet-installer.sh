#! /usr/bin/env bash

main_loop() {
    download_runtime
    
    echo "Extracting tar.gz into $HOME/.local/share/dotnet/runtime/1.1.1..."
    mkdir -p $HOME/.local/share/dotnet/runtime/1.1.1 2> /dev/null

    if [ $? -eq 0 ]; then
        tar zxf /tmp/dotnet-runtime.tar.gz -C $HOME/.local/share/dotnet/runtime/1.1.1 2> /dev/null
    else
        echo "Install failed: Error making directory $HOME/.local/share/dotnet/runtime/1.1.1"
        exit 1
    fi

    if [ $? -eq 0 ]; then
        rm /tmp/dotnet-runtime.tar.gz;

        mkdir -p $HOME/.local/share/dotnet/bin
        ln -s $HOME/.local/share/dotnet/runtime/1.1.1/dotnet $HOME/.local/share/dotnet/bin/dotnet

        if ! [ -z $VERB ]; then echo "Setting $HOME/.local/share/dotnet/bin/dotnet as executable..."; fi
        chmod +x $HOME/.local/share/dotnet/runtime/1.1.1/dotnet
        chmod +x $HOME/.local/share/dotnet/bin/dotnet

        PATH_ADD='export PATH="$PATH:$HOME/.local/share/dotnet/bin"'

        if ! (grep -qF "$PATH_ADD" $HOME/.profile); then
            if ! [ -z $VERB ]; then echo "Adding $HOME/.local/share/dotnet/bin to user \$PATH..."; fi
            echo "# Added by .NET Core installer" >> "$HOME/.profile"
            echo $PATH_ADD >> "$HOME/.profile"
            echo >> "$HOME/.profile"
        else
            if ! [ -z $VERB ]; then echo "$HOME/.local/share/dotnet/bin already detected in $HOME/.profile, skip adding to \$PATH."; fi
        fi
        
        echo '.NET runtime installed successfully. You may need to log-out and back in or type ". ~/.profile"" for the changes to take effect.'
        exit 0
    else
        echo "Install failed: Error encountered while extracting dotnet-runtime.tar.gz"
        exit 1
    fi
}

download_runtime() {
    source /etc/os-release
    export OS_NAME=$NAME
    export OS_ID=$ID
    export OS_VERSION=$VERBSION_ID
    export OS_CODENAME=$VERBSION_CODENAME
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
            curl -SL -o /tmp/dotnet-runtime.tar.gz https://go.microsoft.com/fwlink/?linkid=843432
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
            curl -SL -ov /tmp/dotnet-runtime.tar.gz https://go.microsoft.com/fwlink/?linkid=843422 2> /dev/null
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
            curl -SL -o /tmp/dotnet-runtime.tar.gz https://go.microsoft.com/fwlink/?linkid=847099 2> /dev/null
            if [ $? -eq 0 ]; then return 0; fi
            ;;
        "24")
            echo "Downloading .NET runtime for $OS_ID.$OS_VERSION-x64..."
            curl -SL -o /tmp/dotnet-runtime.tar.gz https://go.microsoft.com/fwlink/?linkid=847099 2> /dev/null
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
