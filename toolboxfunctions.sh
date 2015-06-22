################################################################################
#       _______  _______  _______  ___        _______  _______  __   __ 
#      |       ||       ||       ||   |      |  _    ||       ||  |_|  |
#      |_     _||   _   ||   _   ||   |      | |_|   ||   _   ||       |
#        |   |  |  | |  ||  | |  ||   |      |       ||  | |  ||       |
#        |   |  |  |_|  ||  |_|  ||   |___   |  _   | |  |_|  | |     | 
#        |   |  |       ||       ||       |  | |_|   ||       ||   _   |
#        |___|  |_______||_______||_______|  |_______||_______||__| |__|
#  _______  __   __  __    _  _______  _______  ___   _______  __    _  _______ 
# |       ||  | |  ||  |  | ||       ||       ||   | |       ||  |  | ||       |
# |    ___||  | |  ||   |_| ||       ||_     _||   | |   _   ||   |_| ||  _____|
# |   |___ |  |_|  ||       ||       |  |   |  |   | |  | |  ||       || |_____ 
# |    ___||       ||  _    ||      _|  |   |  |   | |  |_|  ||  _    ||_____  |
# |   |    |       || | |   ||     |_   |   |  |   | |       || | |   | _____| |
# |___|    |_______||_|  |__||_______|  |___|  |___| |_______||_|  |__||_______|
# 
# This file is a set of functions that can be used for multi-purpose purposes
################################################################################

################################################################################
# Is just like the dirname binary.
# This function can take arguements or piped input
dirName()
{
  if    [ "${#*}" -ne "0" ]
  then  while [ "${#*}" -ne "0" ] ; do echo "${1%/*}" ; shift ; done
  else  while read DIR ; do echo "${DIR%/*}" ; done
  fi
}

################################################################################
# Takes input from a pipe.
# Appends current date to every line of input
appendDate()
{
    ( while IFS= read -r line ; do printf "%s %s\n" "$(date +%D_%H:%M:%S):" "$line" ; done )
}

################################################################################
# Backs up a file
# Receives one arguement ( the file you want to backup )
backupFile()
{
  (
    CUR_BACKUP_FILE="${1}" ; EPOCH_NS=$( date +%s-%N )
    cp -p "${CUR_BACKUP_FILE}" "${CUR_BACKUP_FILE}-${EPOCH_NS}"
    if      [ -f "${CUR_BACKUP_FILE}-${EPOCH_NS}" ]
    then    echo "# backupFile() SUCCESS: ${CUR_BACKUP_FILE} --> ${CUR_BACKUP_FILE}-${EPOCH_NS}" ; RC=0
    else    echo "# backupFile() FAILED: ${CUR_BACKUP_FILE} --> ${CUR_BACKUP_FILE}-${EPOCH_NS}"  ; RC=1
    fi
  )
}

################################################################################
# Asks user for a password twice
# only asks up to 3 times then exits
# If function succeeds then it sets password to CUR_PASSWORD variable
READ_PASSWORD_FIELD_RESET()
{
  unset PASSWORD_FIELD  PASSWORD_FIELD_0x_ENCODED  PASSWORD_FIELD_URL_ENCODED  PASSWORD_FIELD_HEX_ENCODED  PASSWORD_FIELD_B_ENCODED
}

# When this function prompts for password, set variables PASSWORD_FIELD* for extra options review variables below.
READ_PASSWORD_FIELD()
{
  READ_PASSWORD_FIELD_TIMEOUT=30
  CLEAR_LINE=$'\n\e[1A\e[K'
  CHAR_BACKSPACE=$'\x7F'
  CHAR_STAR=$'\x2A'
   QUOT_REP_THIS=$'\x27'  ;   QUOT_REP_WITH=$'\x27\x5C\x27\x27'
  DQUOT_REP_THIS=$'\x22'  ;  DQUOT_REP_WITH=$'\x5C\x22'
  unset  PASSWORD_FIELD \
         PASSWORD_FIELD_0x_ENCODED \
         PASSWORD_FIELD_URL_ENCODED \
         PASSWORD_FIELD_HEX_ENCODED \
         PASSWORD_FIELD_B_ENCODED  \
         CHAR_IDX \
         CHAR_IN \
         READ_RETURN \
         READ_TIMEOUT_COUNT \
         READ_PASSWORD_FIELD_OPTIONS
  while [ "${#1}" == "2" ] && [ "${1:0:1}" == "-" ] || [ "${1}" != "${1#-[tT]}" ] || [ "${1}" != "${1#-[hH]*}" ] || [ "${1}" != "${1#--[hH]*}" ] ; do
        READ_PASSWORD_FIELD_OPTIONS[${#READ_PASSWORD_FIELD_OPTIONS[@]}]=${1:0:2}
        if    [ "${1}" != "${1#-[tT]}" ]
        then
              if    [ ${#1} -gt 2 ] && [ "${1%-[tT]*[0-9]}" == "" ]
              then  READ_PASSWORD_FIELD_OPTIONS[${#READ_PASSWORD_FIELD_OPTIONS[@]}]=${1#-[tT]} ; READ_PASSWORD_FIELD_TIMEOUT=${1#-[tT]} ; shift
              elif  [ ${#2} -gt 0 ] && [ "${2//[0-9]}" == "" ]
              then  READ_PASSWORD_FIELD_OPTIONS[${#READ_PASSWORD_FIELD_OPTIONS[@]}]=${2} ; READ_PASSWORD_FIELD_TIMEOUT=${2} ; shift 2
              fi
        elif  [ "${1}" != "${1#-[hH]*}" ]
        then
              printf "%s\n" \
                            "#   usage:  READ_PASSWORD_FIELD  OPTIONS   \"PROMPT\"" "" \
                            "#   usage:  READ_PASSWORD_FIELD  -x,-b,-e,-p,-u OR  -v   AND-OR   -t[TIMEOUT_IN_SECONDS] OR -t [TIMEOUT_IN_SECONDS]   AND-OR   \"Prompt:\"" "" \
                            "# examples:" "" \
                            "          # Get password from user, then echo the value in \${PASSWORD_FIELD}"   "            READ_PASSWORD_FIELD  ; echo \"\${PASSWORD_FIELD}\"" "" \
                            "          # Show all PASSWORD_FIELD*            keys/values"  "            READ_PASSWORD_FIELD  -v" "" \
                            "          # Show     PASSWORD_FIELD_0x_ENCODED  key/value"    "            READ_PASSWORD_FIELD  -x" "" \
                            "          # Show     PASSWORD_FIELD_B_ENCODED   key/value"    "            READ_PASSWORD_FIELD  -b" "" \
                            "          # Show     PASSWORD_FIELD_HEX_ENCODED key/value"    "            READ_PASSWORD_FIELD  -e" "" \
                            "          # Show     PASSWORD_FIELD_URL_ENCODED key/value"    "            READ_PASSWORD_FIELD  -u" "" \
                            "          # Set      READ_TIMEOUT_COUNT=20"                   "            READ_PASSWORD_FIELD  -t20" "" \
                            "          # Show     PASSWORD_FIELD_HEX_ENCODED and PASSWORD_FIELD_URL_ENCODED keys/values , Set READ_TIMEOUT_COUNT=15"    "            READ_PASSWORD_FIELD  -e -u -t15" "" \
                            "          # Use \${PASSWORD_FIELD_B_ENCODED} with a printf statement"  "            READ_PASSWORD_FIELD ; printf \"%b\" \"${PASSWORD_FIELD_B_ENCODED}\"" "" \
                            "          # Set      PROMPT=\"Social Security Number:\""      "            READ_PASSWORD_FIELD  \"Social Security Number:\"" ""  >&2
              return 1
        else
              shift
        fi
  done
  READ_PASSWORD_FIELD_TIMEOUT=${READ_PASSWORD_FIELD_TIMEOUT//[^0-9]}
  if    [ ${#*} -eq 0 ]
  then  READ_PASSWORD_FIELD_QUESTION="Password[\${#PASSWORD_FIELD}]:"
  else  READ_PASSWORD_FIELD_QUESTION="${*}"
  fi
  READ_PASSWORD_FIELD_QUESTION=${READ_PASSWORD_FIELD_QUESTION//${DQUOT_REP_THIS}/${DQUOT_REP_WITH}}
  if    [ "${READ_PASSWORD_FIELD_QUESTION:0:2}" == "\\-" ]
  then  READ_PASSWORD_FIELD_QUESTION=${READ_PASSWORD_FIELD_QUESTION:1}
  fi
  trap 'CHAR_IN_PRINTABLE="" ; break 2>/dev/null'   SIGINT  SIGQUIT  SIGKILL  SIGTERM
  eval READ_PASSWORD_FIELD_QUESTION_PREFIX="\${CLEAR_LINE}${READ_PASSWORD_FIELD_QUESTION}"
  printf "%s" "${READ_PASSWORD_FIELD_QUESTION_PREFIX} " >&2
  while IFS= read -r -n 1 -s -t 1 CHAR_IN ; READ_RETURN=$? ; do
        if    [ ${READ_RETURN} -eq 0 ]
        then
              if    [ ${#CHAR_IN} -eq 0 ]
              then  CHAR_IN_PRINTABLE="" ; break
              elif  [ "${CHAR_IN}" == "${CHAR_BACKSPACE}" ]
              then
                    [ ${#PASSWORD_FIELD} -gt 0 ] && PASSWORD_FIELD=${PASSWORD_FIELD:0: ${#PASSWORD_FIELD} - 1} || PASSWORD_FIELD=
                    if [ ${#PASSWORD_FIELD} -gt 0 ] ; then CHAR_IN_PRINTABLE="*" ; else  CHAR_IN_PRINTABLE="" ; fi
              else
                    PASSWORD_FIELD=${PASSWORD_FIELD}${CHAR_IN}
                    CHAR_IN_PRINTABLE=${CHAR_IN}
              fi
              READ_TIMEOUT_COUNT=0
        else
              if [ ${#PASSWORD_FIELD} -gt 0 ] ; then CHAR_IN_PRINTABLE="*" ; else  CHAR_IN_PRINTABLE="" ; fi
              READ_TIMEOUT_COUNT=$(( READ_TIMEOUT_COUNT + 1 ))
              [ ${READ_TIMEOUT_COUNT} -ge ${READ_PASSWORD_FIELD_TIMEOUT:-20} ] && break
        fi
        PASSWORD_FIELD_STARS=${PASSWORD_FIELD//[^${CHAR_STAR}]/${CHAR_STAR}}"*"
        eval READ_PASSWORD_FIELD_QUESTION_PREFIX="\${CLEAR_LINE}${READ_PASSWORD_FIELD_QUESTION}"
        if    [ ${#PASSWORD_FIELD} -eq 0 ]
        then  READ_PASSWORD_FIELD_QUESTION_SUFFIX=""
        else  READ_PASSWORD_FIELD_QUESTION_SUFFIX="${PASSWORD_FIELD_STARS: 0:${#PASSWORD_FIELD} - 1}${CHAR_IN_PRINTABLE}"
        fi
        printf "%s" "${READ_PASSWORD_FIELD_QUESTION_PREFIX} ${READ_PASSWORD_FIELD_QUESTION_SUFFIX}" >&2
  done
  printf "%s" "${READ_PASSWORD_FIELD_QUESTION_PREFIX} ${PASSWORD_FIELD//[^${CHAR_STAR}]/${CHAR_STAR}}" >&2
  printf "\n" >&2
  PASSWORD_FIELD_URL_ENCODED="$( which hexdump >/dev/null 2>/dev/null && printf "%s" "${PASSWORD_FIELD}" | hexdump -v -e "1/1 \" %02X\"" | sed -e s," ","%",g  -e s,"$","\n",g )"
  PASSWORD_FIELD_HEX_ENCODED=${PASSWORD_FIELD_URL_ENCODED//%/ }
  PASSWORD_FIELD_0x_ENCODED=${PASSWORD_FIELD_URL_ENCODED//%/0x}
  PASSWORD_FIELD_B_ENCODED=${PASSWORD_FIELD_URL_ENCODED//%/\\x}
     [ "${READ_PASSWORD_FIELD_OPTIONS[*]}" != "${READ_PASSWORD_FIELD_OPTIONS[*]//-[xX]}" ] \
  || [ "${READ_PASSWORD_FIELD_OPTIONS[*]}" != "${READ_PASSWORD_FIELD_OPTIONS[*]//-[vV]}" ] \
  && printf "PASSWORD_FIELD_0x_ENCODED=\x27%s\x27\n"   "${PASSWORD_FIELD_0x_ENCODED}"
     [ "${READ_PASSWORD_FIELD_OPTIONS[*]}" != "${READ_PASSWORD_FIELD_OPTIONS[*]//-[bB]}" ] \
  || [ "${READ_PASSWORD_FIELD_OPTIONS[*]}" != "${READ_PASSWORD_FIELD_OPTIONS[*]//-[vV]}" ] \
  && printf "PASSWORD_FIELD_B_ENCODED=\x27%s\x27\n"   "${PASSWORD_FIELD_B_ENCODED}"
     [ "${READ_PASSWORD_FIELD_OPTIONS[*]}" != "${READ_PASSWORD_FIELD_OPTIONS[*]//-[eE]}" ] \
  || [ "${READ_PASSWORD_FIELD_OPTIONS[*]}" != "${READ_PASSWORD_FIELD_OPTIONS[*]//-[vV]}" ] \
  && printf "PASSWORD_FIELD_HEX_ENCODED=\x27%s\x27\n"   "${PASSWORD_FIELD_HEX_ENCODED}"
     [ "${READ_PASSWORD_FIELD_OPTIONS[*]}" != "${READ_PASSWORD_FIELD_OPTIONS[*]//-[uU]}" ] \
  || [ "${READ_PASSWORD_FIELD_OPTIONS[*]}" != "${READ_PASSWORD_FIELD_OPTIONS[*]//-[vV]}" ] \
  && printf "PASSWORD_FIELD_URL_ENCODED=\x27%s\x27\n" "${PASSWORD_FIELD_URL_ENCODED}"
     [ "${READ_PASSWORD_FIELD_OPTIONS[*]}" != "${READ_PASSWORD_FIELD_OPTIONS[*]//-[pP]}" ] \
  || [ "${READ_PASSWORD_FIELD_OPTIONS[*]}" != "${READ_PASSWORD_FIELD_OPTIONS[*]//-[vV]}" ] \
  && printf "PASSWORD_FIELD=\x27%s\x27\n"   "${PASSWORD_FIELD//${QUOT_REP_THIS}/${QUOT_REP_WITH}}"
  unset ${!READ_PASSWORD_FIELD*} PASSWORD_FIELD_STARS  CHAR_IN_PRINTABLE  CHAR_IN  READ_TIMEOUT_COUNT  READ_RETURN
  trap - SIGINT SIGQUIT SIGKILL SIGTERM
  [ ${#PASSWORD_FIELD} -gt 0 ] && return 0 || return 255
}

################################################################################
# Another iteration of getPassword but requires you to have a checker. 
# getPassword2() 
# {
#           CLEAR_LINE=$'\n\e[1A\e[K' ; CHAR_BACKSPACE=$'\x7F' PASSWORD_FIELD="" ; CHAR_IDX=0 ; CHAR_IN=
#           printf "%s"  "${CLEAR_LINE}"  "${*:-Password: }"
#           while IFS= read -r -n 1 -s CHAR_IN  ; do
#                 if    [ ${#CHAR_IN} -eq 0 ]
#                 then  break
#                 elif  [ "${CHAR_IN}" == "${CHAR_BACKSPACE}" ]
#                 then  [ ${#PASSWORD_FIELD} -gt 0 ] && PASSWORD_FIELD=${PASSWORD_FIELD:0: ${#PASSWORD_FIELD} - 1}
#                 else  PASSWORD_FIELD=${PASSWORD_FIELD}${CHAR_IN}
#                 fi
#                 PASSWORD_FIELD_STARS=${PASSWORD_FIELD//[^\*]/\*}
#                 if    [ ${#PASSWORD_FIELD} -eq 0 ]
#                 then  printf "%s"  "${CLEAR_LINE}"  "Password: "
#                 else  printf "%s"  "${CLEAR_LINE}"  "Password: ${PASSWORD_FIELD_STARS: 0:${#PASSWORD_FIELD_STARS} - 1}${CHAR_IN//${CHAR_BACKSPACE}/*}"
#                 fi
#                 sleep 0.15
#                 printf "%s"  "${CLEAR_LINE}"  "Password: ${PASSWORD_FIELD_STARS}"
#           done
#           printf "\n" 
# }



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

################################################################################
# Function provided by zhoul
# Set a variable and then use that variable as an arguement.
# Sets array name ${ARRAY[@]}
# Good for small arrays
arrayFromString()
{
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
arrayFromPipe()
{
    echo unset ARRAY
    sed -e s,"\x27","\x27\x5C\x5C\x27\x27",g \
        -e s,"^\(.*\)$","ARRAY[\${#ARRAY[@]}]=\x27\1\x27",g
    echo ""
}


################################################################################
#       _______  _______  _______  ___        _______  _______  __   __ 
#      |       ||       ||       ||   |      |  _    ||       ||  |_|  |
#      |_     _||   _   ||   _   ||   |      | |_|   ||   _   ||       |
#        |   |  |  | |  ||  | |  ||   |      |       ||  | |  ||       |
#        |   |  |  |_|  ||  |_|  ||   |___   |  _   | |  |_|  | |     | 
#        |   |  |       ||       ||       |  | |_|   ||       ||   _   |
#        |___|  |_______||_______||_______|  |_______||_______||__| |__|
#  _______  __   __  __    _  _______  _______  ___   _______  __    _  _______ 
# |       ||  | |  ||  |  | ||       ||       ||   | |       ||  |  | ||       |
# |    ___||  | |  ||   |_| ||       ||_     _||   | |   _   ||   |_| ||  _____|
# |   |___ |  |_|  ||       ||       |  |   |  |   | |  | |  ||       || |_____ 
# |    ___||       ||  _    ||      _|  |   |  |   | |  |_|  ||  _    ||_____  |
# |   |    |       || | |   ||     |_   |   |  |   | |       || | |   | _____| |
# |___|    |_______||_|  |__||_______|  |___|  |___| |_______||_|  |__||_______|
# 
# End of TOOL BOX FUNCTIONS
################################################################################