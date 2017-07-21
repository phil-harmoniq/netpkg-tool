#! /usr/bin/env bash

# Store variables from C#
PROJECT="$1"
APP_NAME="$2"
CORE_VERS="$3"
MAKE_SCD="$4"

echo "$PROJECT $APP_NAME $CORE_VERS $MAKE_SCD"

set -e

# Remove old temp folder & make new one
rm -rf /tmp/"$APP_NAME".temp
mkdir -p /tmp/"$APP_NAME".temp/usr/bin
mkdir -p /tmp/"$APP_NAME".temp/usr/share/app

# Transfer files from publish folder into temp folder
if [[ -z $MAKE_SCD ]]; then
    cp -r "$PROJECT"/bin/Release/"$CORE_VERS"/publish/. /tmp/"$APP_NAME".temp/usr/share/app
else
    cp -r "$PROJECT"/bin/Release/"$CORE_VERS"/linux-x64/publish/. /tmp/"$APP_NAME".temp/usr/share/app
fi

# Create an AppRun launcher
touch /tmp/"$APP_NAME".temp/AppRun
{
    echo '#! /usr/bin/env bash'
    echo
    echo 'export HERE=$(dirname "$(readlink -f "${0}")")'
    if [[ -z $MAKE_SCD ]]; then
        echo 'dotnet $HERE/usr/share/app/'"$APP_NAME.dll"' $@'
    else
        echo '$HERE/usr/share/app/'"$APP_NAME"' $@'
    fi
    echo
} >> /tmp/"$APP_NAME".temp/AppRun

# Create a desktop entry
touch /tmp/"$APP_NAME".temp/"$APP_NAME".desktop
echo "[Desktop Entry]" >> /tmp/"$APP_NAME".temp/"$APP_NAME".desktop
echo >> /tmp/"$APP_NAME".temp/"$APP_NAME".desktop
echo "Type=Application" >> /tmp/"$APP_NAME".temp/"$APP_NAME".desktop
echo "Name=$APP_NAME" >> /tmp/"$APP_NAME".temp/"$APP_NAME".desktop
echo "Exec=AppRun" >> /tmp/"$APP_NAME".temp/"$APP_NAME".desktop
echo "Icon=$APP_NAME-icon" >> /tmp/"$APP_NAME".temp/"$APP_NAME".desktop
echo >> /tmp/"$APP_NAME".temp/"$APP_NAME".desktop

# Generate fake app icon (icons aren't supported by appimagetool right now)
touch /tmp/"$APP_NAME".temp/"$APP_NAME"-icon.png

# Set executable
chmod +x /tmp/"$APP_NAME".temp/AppRun

# Delete .NET Core debug databse files
rm -f /tmp/"$APP_NAME".temp/usr/share/app/*.pdb
