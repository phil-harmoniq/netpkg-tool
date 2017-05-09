#! /usr/bin/env bash

if [ -z "$LOC" ]; then NET="${red:-}not installed${normal:-}"
else NET="$(dirname $LOC)"; fi

echo
echo -n "------------------ ${cyan:-}"
echo -n "${bold:-}NET_Pkg.Tool $PKG_VERSION"
echo "${normal:-} -------------------"
echo
echo "            OS: $OS_PNAME"
echo " .NET location: $NET"
echo
echo "   Usage:"
echo "  ./NET_Pkg.Tool [.NET Project] [Destination] [flags]"
echo
echo "   Optional Arguments:"
echo "      -verbose or -v : Verbose output"
echo "         -help or -h : Help menu (this page)"
echo "          -dir or -d : View location of .NET runtime"
echo
echo "---------------------------------------------------------"
echo

exit 0
