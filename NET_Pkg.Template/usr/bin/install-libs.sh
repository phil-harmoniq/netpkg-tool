#! /usr/bin/env bash

main_loop() {
    if [[ $need_unwind == "true" ]]; then get_libunwind; fi
    if [[ $need_icu == "true" ]]; then get_libicu; fi
    # if [[ $need_gettext == "true" ]]; then get_gettext; fi
    # if [[ $need_curl == "true" ]]; then get_curl; fi
}

get_libunwind() {
    echo "Downloading libunwind..."
    wget http://download.savannah.nongnu.org/releases/libunwind/libunwind-1.2.tar.gz -O /tmp/libunwind.tar.gz -q --show-progress
    mkdir -p /tmp/.unwind-unpack
    tar zxf /tmp/libunwind.tar.gz -C /tmp/.unwind-unpack &> /dev/null

    echo "Compiling libunwind from source. This may take a while."
    compile_libunwind
    rm -rf /tmp/.unwind-unpack
}

compile_libunwind() {
    cd /tmp/.unwind-unpack/libunwind-1.2
    ./configure --prefix=$HOME/.local/share/dotnet/deps
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
