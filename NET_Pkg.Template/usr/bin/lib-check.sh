#! /usr/bin/env sh

# ------------------------------- Functions ------------------------------

main_loop() {
    check_libunwind &> /dev/null
    check_libicu &> /dev/null
    # check_gettext &> /dev/null
    # check_curl
}

check_libunwind() {
    /sbin/ldconfig -N -v $(sed 's/:/ /' <<< $LD_LIBRARY_PATH) | grep libunwind
    if [[ $? == 0 ]]; then
        return 0
    else
        export need_unwind="true"
        export libs_needed="true"
        return 1
    fi
}

check_libicu() {
    /sbin/ldconfig -N -v $(sed 's/:/ /' <<< $LD_LIBRARY_PATH) | grep libicu
    if [[ $? == 0 ]]; then
        return 0
    else
        export need_icu="true"
        export libs_needed="true"
        return 1
    fi
}

check_gettext() {
    echo which gettext
    if [[ $? == 0 ]]; then
        return 0
    else
        export need_gettext="true"
        export libs_needed="true"
        return 1
    fi
}

# --------------------------------- Init ---------------------------------

main_loop
