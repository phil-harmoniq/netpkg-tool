#! /usr/bin/env bash

# Store variables from C#
PROJECT="$1"
DLL_NAME="$2"
APP_NAME="$3"
CORE_VERS="$4"
NET_PKG="$5"
MAKE_SCD="$6"

# Hard exit if any part of the script fails
set -e

# Remove old temp folder & make new one
rm -rf /tmp/"$APP_NAME".temp
mkdir -p /tmp/"$APP_NAME".temp/usr/share/"$APP_NAME"

# Transfer files from publish folder into temp folder
if [[ $MAKE_SCD == "true" ]]; then
    cp -r "$PROJECT"/bin/Release/"$CORE_VERS"/linux-x64/publish/. /tmp/"$APP_NAME".temp/usr/share/"$APP_NAME"
else
    cp -r "$PROJECT"/bin/Release/"$CORE_VERS"/publish/. /tmp/"$APP_NAME".temp/usr/share/"$APP_NAME"
fi

# Create an AppRun launcher
touch /tmp/"$APP_NAME".temp/AppRun
{
    echo '#! /usr/bin/env bash'
    echo
    echo 'export HERE=$(dirname "$(readlink -f "${0}")")'
    echo 'export NET_PKG='\""$NET_PKG"\"

    if [[ -d $PROJECT/netpkg.lib ]]; then
        echo 'if [[ -z $LD_LIBRARY_PATH ]]; then export LD_LIBRARY_PATH="$HERE/usr/lib"'
        echo 'else export LD_LIBRARY_PATH="$HERE:/usr/lib:$LD_LIBRARY_PATH"; fi'
    fi

    if [[ -z $MAKE_SCD ]]; then
        echo 'exec -a "'"$APP_NAME"'" dotnet "$HERE/usr/share/'"$APP_NAME"'/'"$DLL_NAME.dll"'" "$@"'
    else
        echo 'exec -a "'"$APP_NAME"'" "$HERE/usr/share/'"$APP_NAME"'/'"$DLL_NAME"'" "$@"'
    fi
} >> /tmp/"$APP_NAME".temp/AppRun

# Create a desktop entry
touch /tmp/"$APP_NAME".temp/"$APP_NAME".desktop
{
    echo '[Desktop Entry]'
    echo
    echo 'Type=Application'
    echo "Name=$APP_NAME"
    echo 'Exec=AppRun'
    echo "Icon=$APP_NAME-icon"
} >> /tmp/"$APP_NAME".temp/"$APP_NAME".desktop

# Generate fake app icon (icons aren't supported by appimagetool right now)
touch /tmp/"$APP_NAME".temp/"$APP_NAME"-icon.png

# Set executable
chmod a+x /tmp/"$APP_NAME".temp/AppRun

# Check for netpkg.lib and import libraries
if [[ -d $PROJECT/netpkg.lib ]]; then
    mkdir -p /tmp/"$APP_NAME".temp/usr/lib
    cp -a -L "$PROJECT"/netpkg.lib/. /tmp/"$APP_NAME".temp/usr/lib/
fi

# Delete .NET Core debug databse files
rm -f /tmp/"$APP_NAME".temp/usr/share/"$APP_NAME"/*.pdb
