#! /usr/bin/env sh

main_loop() {
    set -e

    if [[ $need_unwind == "true" ]]; then get_libunwind; fi
    if [[ $need_icu == "true" ]]; then get_libicu; fi
    # if [[ $need_gettext == "true" ]]; then get_gettext; fi
    # if [[ $need_curl == "true" ]]; then get_curl; fi

    unset -e
}

get_libunwind() {
    echo "Downloading libunwind..."
    wget https://download.microsoft.com/download/0/6/5/0656B047-5F2F-4281-A851-F30776F8616D/dotnet-dev-linux-x64.2.0.0-preview1-005977.tar.gz -O /tmp/libunwind.tar.gz -q --show-progress
    mkdir -p /tmp/.unwind-unpack
    tar zxf /tmp/libunwind.tar.gz -C /tmp/.unwind-unpack &> /dev/null

    echo "Compiling libunwind from source. This may take a while."
    compile_libunwind &> /dev/null
    rm -rf /tmp/.unwind-unpack
}

compile_libunwind() {
    cd /tmp/.unwind-unpack
    ./configure.sh --prefix=$HOME/.local/share/dotnet/deps
    make
    make install
}

get_libicu() {
    echo "Downloading libicu..."
    wget http://download.icu-project.org/files/icu4c/59.1/icu4c-59_1-Fedora25-x64.tgz -O /tmp/libicu.tar.gz -q --show-progress
    mkdir -p /tmp/.icu-unpack
    tar zxf /tmp/libicu.gz -C /tmp/.icu-unpack &> /dev/null
    cp -r /tmp/.icu-unpack/icu/usr/local $HOME/.local/share/dotnet/deps
    rm -rf /tmp/.unwind-unpack
}

get_gettext() {
    echo "Downloading gettext..."
    wget http://ftp.br.debian.org/debian/pool/main/g/gettext/gettext_0.19.3-2_amd64.deb -O /tmp/gettext.deb -q --shop-progress
}

main_loop
