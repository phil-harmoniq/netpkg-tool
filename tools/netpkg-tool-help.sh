#! /usr/bin/env bash

if [[ -z "$NET_LOC" ]]; then NET="${red:-}not installed${normal:-}"
else NET="$(dirname $NET_LOC)"; fi

echo
echo -n "----------------------- ${cyan:-}"
echo -n "${bold:-}netpkg-tool $PKG_VERSION"
echo "${normal:-} -------------------------"
echo
echo "                ${bold:-}${cyan:-}Info:${normal:-}"
echo "                  OS: $OS_PNAME"
echo "       .NET location: $NET"
echo
echo "               ${bold:-}${cyan:-}Usage:${normal:-}"
echo "    ./netpkg-tool [Project Directory] [Destination] [Flags]"
echo
echo "      ${bold:-}${cyan:-}Optional Flags:${normal:-}"
echo "     --verbose or -v: Verbose output"
echo "     --compile or -c: Skip checks & dotnet-restore"
echo "        --name or -n: Set ouput file to custom name"
echo "         --scd or -s: Self-Contained Deployment (SCD)"
echo "     --scd-rid or -r: SCD with custom RID (default: linux-x64)"
echo "        --keep or -k: Keep /tmp/npk.temp directory"
echo
echo "     ${bold:-}${cyan:-}Extra Functions:${normal:-}"
echo "        --help or -h: Help menu (this page)"
echo "       --install-sdk: Install .NET SDK locally"
echo "     --uninstall-sdk: Remove local .NET SDK install"
echo
echo "    More information & source code available on github:"
echo "    https://github.com/phil-harmoniq/NET_Pkg"
echo "    Copyright (c) 2017 - MIT License"
echo
echo "-------------------------------------------------------------------"
echo

exit 0
