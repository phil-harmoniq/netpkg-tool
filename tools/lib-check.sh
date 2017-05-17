#! /usr/bin/env sh

# ------------------------------- Functions ------------------------------

main_loop() {
}

check_libunwind() {
    /sbin/ldconfig -N -v $(sed 's/:/ /' <<< $LD_LIBRARY_PATH) | grep libunwind &> /dev/null
    if [[ $? == 0 ]]; then return 0; else return 1; fi
}

check_libicu() {
    /sbin/ldconfig -N -v $(sed 's/:/ /' <<< $LD_LIBRARY_PATH) | grep libicu &> /dev/null
    if [[ $? == 0 ]]; then return 0; else return 1; fi
}

check_gettext() {
    echo which gettest &> /dev/null
    if [[ $? == 0 ]]; then return 0; else return 1; fi
}

# ------------------------------- Variables ------------------------------



# ---------------------------- Optional Args -----------------------------

if [[ "${ARGS[2]}" == "-v" ]] || [[ "${ARGS[0]}" == "--verbose" ]]; then
    export VERB="true"
elif [[ "${ARGS[2]}" == "--nodel" ]]; then
    export NO_DEL="true"
fi

# --------------------------------- Init ---------------------------------

main_loop
