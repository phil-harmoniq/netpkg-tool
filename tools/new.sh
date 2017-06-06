new_standard_lib() {
    say_hello
    fullpath="$(readlink -m $(pwd)/$3)"
    echo "${cyan:-}Create .NET Standard project at $DIR_REL/$3${normal:-}"

    mkdir -p "$3" && cd "$3"

    echo -n "Creating .sln in root directory..."
    dotnet new sln -n "$3" &> /dev/null

    if [[ $? -eq 0 ]]; then say_pass; else say_fail; exit 1; fi

    echo -n "Creating .NET Standard library $3..."
    dotnet new classlib -n "$3" &> /dev/null

    if [[ $? -eq 0 ]]; then say_pass; else say_fail; exit 1; fi

    echo -n "Creating .NET console application TestApp..."
    dotnet new console -n TestApp &> /dev/null

    if [[ $? -eq 0 ]]; then say_pass; else say_fail; exit 1; fi

    echo -n "Adding project references..."
    dotnet sln add "$3"/"$3".csproj &> /dev/null

    if [[ $? -eq 0 ]]; then
        dotnet sln add "$3"/"$3".csproj &> /dev/null
    else
        say_fail
        exit 1
    fi

    if [[ $? -eq 0 ]]; then
        dotnet sln add TestApp/TestApp.csproj &> /dev/null
    else
        say_fail
        exit 1
    fi

    if [[ $? -eq 0 ]]; then
        dotnet add TestApp/TestApp.csproj reference "$3"/"$3".csproj &> /dev/null
    else
        say_fail
        exit 1
    fi
    
    if [[ $? -eq 0 ]]; then say_pass; else say_fail; exit 1; fi

    echo -n "Restoring project dependencies..."
    dotnet restore &> /dev/null

    if [[ $? -eq 0 ]]; then say_pass; else say_fail; exit 1; fi

    echo "${green:-}New project succesfully created at $DIR_REL/$3${normal:-}"

    say_bye
}

say_hello() {
    echo
    echo -n "------------------ ${cyan:-}"
    echo -n "${bold:-}NET_Pkg.Tool $PKG_VERSION"
    echo "${normal:-} -------------------"
}

say_bye() {
    echo "---------------------------------------------------------"
    echo
}

say_pass() {
    echo "${bold:-} [ ${green:-}PASS${white:-} ]${normal:-}"
}

say_warning() {
    echo "${bold:-} [ ${yellow:-}FAIL${white:-} ]${normal:-}"
}

say_fail() {
    echo "${bold:-} [ ${red:-}FAIL${white:-} ]${normal:-}"
}

get_dir_relative() {
    pwd_dir=$(pwd)
    cd "$3"
    export DIR_REL="$(dirs -0)"
    cd "$pwd_dir"
}

# ------------------------------- Variables ------------------------------

get_dir_relative

# -------------------------------- Options -------------------------------

if [[ "$2" == "lib" ]]; then
    if [[ -z "$3" ]]; then
        echo "${red:-}You must specify a name for your new project.${normal:-}"
    elif [[ -d "$(pwd)/$3" ]]; then
        pwd_rel=$(dirs -0)
        echo "${red:-}Directory $pwd_rel/$3 already exists.${normal:-}"
        exit 1
    else
        new_standard_lib $@
    fi
else
    echo "${red:-}You must specify a project type: netpkg-tool --new [type]${normal:-}"
fi
