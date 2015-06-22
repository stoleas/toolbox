#!/bin/bash

################################################################################
# Function provided by zhoul
# Set a variable and then use that variable as an arguement.
# Sets array name ${ARRAY[@]}
# Good for small arrays
arrayFromString() {
    ARRAY=( )
    AFV_CHAR_NL=$'\n'
    AFV_SIDX=0
    AFV_AIDX=0
    while [ ${#*} -ne 0 ] ; do
          AFV_STR=${1}
          while [ ${AFV_SIDX} -lt ${#AFV_STR} ] ; do
                if    [ "${AFV_STR:SIDX:1}" == "${CHAR_NL}" ]
                then  AIDX=$(( AIDX + 1 )) ; ARRAY[AFV_AIDX]=""
                else  ARRAY[AIDX]=${ARRAY[AIDX]}${AFV_STR:AFV_SIDX:1}
                fi
                AFV_SIDX=$(( AFV_SIDX + 1 ))
          done
          shift
    done
}

################################################################################
# Function provided by zhoul
# Set a variable and then pipe it to this function. EXAMPLE: eval "$(echo "${VARIABLE}" | arrayFromPipe)"
# Sets array name ${ARRAY[@]}
# Good for large arrays
arrayFromPipe() {
    echo unset ARRAY
    sed -e s,"\x27","\x27\x5C\x5C\x27\x27",g \
        -e s,"^\(.*\)$","ARRAY[\${#ARRAY[@]}]=\x27\1\x27",g
    echo ""
}

arrayFromVar() {
  # Script 1 is done up in bash.  Great for short bursts, but slow with large data.
  # Script 2 is done up with pipes to cat and sed - far faster.

  VAR2ARRAY_SCRIPT_1='
                        V2A_NEW_LINE=$'\''\n'\''
                        V2A_DELIM=${V2A_NEW_LINE}
                        V2A_IDX=0
                        V2A_IDX_MAX=${#VAR2ARRAY}
                        V2A_IDX_CUR=0
                        V2A_RECORD=0
                        
                        VAR2ARRAY_ARRAY=(  )
    
                        VAR2ARRAY_TEMP_VAR=${VAR2ARRAY}${V2A_NEW_LINE}
    
                        while [ ${#VAR2ARRAY_TEMP_VAR} -gt 0 ] ; do
                              VAR2ARRAY_ARRAY[V2A_IDX]=${VAR2ARRAY_TEMP_VAR%%${V2A_NEW_LINE}*}
                              VAR2ARRAY_TEMP_VAR=${VAR2ARRAY_TEMP_VAR#*${V2A_NEW_LINE}}
                              V2A_IDX=$(( V2A_IDX + 1 ))
                        done
    
                        if    [ "${#VAR2ARRAY_ARRAY[@]}" -gt 0 ]
                        then
                              [ -t 1 ] && printf "%s\n" "# \"\${VAR2ARRAY_ARRAY[@]}\""
                              return 0
                        else
                              return 1
                        fi
    
                        unset  VAR2ARRAY_TEMP_VAR

                      '

  VAR2ARRAY_SCRIPT_2='

                        unset  VAR2ARRAY_ARRAY

                        eval "$( printf "%s\n" "${VAR2ARRAY[@]}"  | cat -n | sed  -e s,"\x27","\x27\\\\\x27\x27",g  -e s,"^[^0-9]*\([0-9][0-9]*\)[^0-9][^0-9]*\(.*\)$","VAR2ARRAY_ARRAY[\1]=\x27\2\x27",g )"

                        if    [ "${#VAR2ARRAY_ARRAY[@]}" -gt 0 ]
                        then
                              [ -t 1 ] && printf "%s\n" "# \"\${VAR2ARRAY_ARRAY[@]}\""
                              return 0
                        else
                              return 1
                        fi

                      '

  eval "[ \${#${1}} -gt 1000000 ] && V2A_SCRIPT=VAR2ARRAY_SCRIPT_2 || V2A_SCRIPT=VAR2ARRAY_SCRIPT_1 ; [ \${#${1}} -gt 0 ] && unset ${1}_ARRAY" && eval V2A_CUR_SCRIPT=\${${V2A_SCRIPT}} && eval "${V2A_CUR_SCRIPT//VAR2ARRAY/${1}}"
}