#! /usr/bin/env bash

if [[ -z "$NET_LOC" ]]; then NET="${red:-}not installed${normal:-}"
else NET="$(dirname $NET_LOC)"; fi

echo
echo -n "------------------ ${cyan:-}"
echo -n "${bold:-}NET_Pkg.Tool $PKG_VERSION"
echo "${normal:-} -------------------"
echo
echo "          ${bold:-}${cyan:-}Info:${normal:-}"
echo "            OS: $OS_PNAME"
echo " .NET location: $NET"
echo
echo "   ${bold:-}${cyan:-}Usage:${normal:-}"
echo "  ./NET_Pkg.Tool [.NET Project] [Destination] [flags]"
echo
echo "   ${bold:-}${cyan:-}Optional Arguments:${normal:-}"
echo "     --verbose or -v : Verbose output"
echo "        --help or -h : Help menu (this page)"
echo "         --dir or -d : View location of .NET runtime"
echo "        --install-sdk: Install the .NET sdk locally"
echo
echo "   More information & source code available on github:"
echo "   https://github.com/phil-harmoniq/NET_Pkg"
echo "   Copyright (c) 2017 - MIT License"
echo
echo "---------------------------------------------------------"
echo

exit 0
