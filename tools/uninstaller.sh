#! /usr/bin/env bash

main_loop() {
    delete_local_files
    remove_from_path
    echo ".NET successfully uninstalled."
    echo
}

delete_local_files() {
    echo -n "Deleting local installation files"
    if [[ -d $HOME/.local/share/dotnet ]]; then
        rm -r $HOME/.local/share/dotnet
        say_pass
    else
        say_caution
        echo "${yellow:-}.NET not detected in $HOME/.local/share/dotnet${normal:-}"
    fi
}

remove_from_path() {
    echo -n 'Removing from User $PATH'
    sed -i '\~# Added by .NET Core installer~d' $HOME/.bashrc
    sed -i '\~export PATH="$HOME/.local/share/dotnet/bin:$PATH"~ {N;s/\n$//}' $HOME/.bashrc
    sed -i '\~export PATH="$HOME/.local/share/dotnet/bin:$PATH"~ d' $HOME/.bashrc
    say_pass
}

say_pass() {
    echo "${bold:-} [ ${green:-}PASS${white:-} ]${normal:-}"
}

say_caution() {
    echo "${bold:-} [ ${yellow:-}PASS${white:-} ]${normal:-}"
}

say_warning() {
    echo "${bold:-} [ ${yellow:-}FAIL${white:-} ]${normal:-}"
}

say_fail() {
    echo "${bold:-} [ ${red:-}FAIL${white:-} ]${normal:-}"
}

main_loop
