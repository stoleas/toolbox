#!/bin/bash
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