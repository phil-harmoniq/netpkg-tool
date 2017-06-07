#! /usr/bin/env bash

# See if stdout is a terminal
if [[ -t 1 ]]; then
    # see if it supports colors
    ncolors=$(tput colors)
    if [[ -n "$ncolors" ]] && [[ $ncolors -ge 8 ]]; then
        export bold="$(tput bold       || echo)"
        export normal="$(tput sgr0     || echo)"
        export black="$(tput setaf 0   || echo)"
        export red="$(tput setaf 1     || echo)"
        export green="$(tput setaf 2   || echo)"
        export yellow="$(tput setaf 3  || echo)"
        export blue="$(tput setaf 4    || echo)"
        export magenta="$(tput setaf 5 || echo)"
        export cyan="$(tput setaf 6    || echo)"
        export white="$(tput setaf 7   || echo)"
    fi
fi
