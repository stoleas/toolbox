#!/bin/bash

################################################################################
# Function provided by zhoul
# Pipe data to it and it will lowercase all letters
CASE_LOWER ()
{ 
    if [ "${1:0:2}" == "-v" ]; then
        CASE_PUT_RESULT_IN_VAR="${1} ${2}";
        shift;
        shift;
    else
        CASE_PUT_RESULT_IN_VAR=;
    fi;
    if [ "${#*}" -eq 0 ]; then
        CASE_OLD_STRING=$( cat );
    else
        CASE_OLD_STRING=${*};
    fi;
    CASE_NEW_STRING=;
    for ((i=0 ; i<=${#CASE_OLD_STRING} ; i++ ))
    do
        printf -v CASE_CUR_CHAR_DEC "%d" "'${CASE_OLD_STRING:${i}:1}";
        if [ "${CASE_CUR_CHAR_DEC}" -ge 65 ] && [ "${CASE_CUR_CHAR_DEC}" -le 90 ]; then
            printf -v CASE_CUR_CHAR_HEX "\\\\x%02x" $(( ${CASE_CUR_CHAR_DEC} + 32 ));
            printf -v CASE_NEW_CHAR "${CASE_CUR_CHAR_HEX}";
        else
            CASE_NEW_CHAR=${CASE_OLD_STRING:${i}:1};
        fi;
        CASE_NEW_STRING=${CASE_NEW_STRING}${CASE_NEW_CHAR};
    done;
    printf ${CASE_PUT_RESULT_IN_VAR} "%s\n" "${CASE_NEW_STRING}"
}

################################################################################
# Function provided by zhoul
# Pipe data to it and it will uppercase all letters
CASE_UPPER ()
{ 
    if [ "${1:0:2}" == "-v" ]; then
        CASE_PUT_RESULT_IN_VAR="${1} ${2}";
        shift;
        shift;
    else
        CASE_PUT_RESULT_IN_VAR=;
    fi;
    if [ "${#*}" -eq 0 ]; then
        CASE_OLD_STRING=$( cat );
    else
        CASE_OLD_STRING=${*};
    fi;
    CASE_NEW_STRING=;
    for ((i=0 ; i<=${#CASE_OLD_STRING} ; i++ ))
    do
        printf -v CASE_CUR_CHAR_DEC "%d" "'${CASE_OLD_STRING:${i}:1}";
        if [ "${CASE_CUR_CHAR_DEC}" -ge 97 ] && [ "${CASE_CUR_CHAR_DEC}" -le 122 ]; then
            printf -v CASE_CUR_CHAR_HEX "\\\\x%02x" $(( ${CASE_CUR_CHAR_DEC} - 32 ));
            printf -v CASE_NEW_CHAR "${CASE_CUR_CHAR_HEX}";
        else
            CASE_NEW_CHAR=${CASE_OLD_STRING:${i}:1};
        fi;
        CASE_NEW_STRING=${CASE_NEW_STRING}${CASE_NEW_CHAR};
    done;
    printf ${CASE_PUT_RESULT_IN_VAR} "%s\n" "${CASE_NEW_STRING}"
}
