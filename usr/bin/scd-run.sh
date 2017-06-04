# If this is the first line of AppRun, new-pkg.sh didn't run properly.
# ------------------------------- Variables ------------------------------

export HERE=$(dirname $(readlink -f "${0}"))
export APPDIR="$HERE/usr/share/app"
export ARGS=($@)
export PATH="$HERE/usr/bin:$PATH"
export PKG_LIB="$HERE/usr/lib"

if [[ -z "${LD_LIBRARY_PATH// }" ]]; then 
    export LD_LIBRARY_PATH="$HERE/usr/lib"
else
    export LD_LIBRARY_PATH="$HERE/usr/lib:$LD_LIBRARY_PATH"
fi

source /etc/os-release
export OS_NAME=$NAME
export OS_ID=$ID
export OS_VERSION=$VERSION_ID
export OS_CODENAME=$VERSION_CODENAME
export OS_PNAME=$PRETTY_NAME

export PKG_VERSION=$PKG_VERSION
export DLL_NAME=$DLL_NAME
export LOC="$(which dotnet 2> /dev/null)"

# --------------------------------- Init ---------------------------------

$APPDIR/$DLL_NAME ${ARGS[@]}
