#!/bin/bash

# PAGE BREAK
PB=$( printf "#%.0s" {1..80} )

GIT_ADD () {
  printf "${PB}\n# Adding Git Files\n${PB}\n"
  git add -A -v .
  printf "\n"
}

GIT_COMMIT () {
  DATE=$(date)
  printf "${PB}\n# Adding Git Files\n${PB}\n"
  if    [ ${#1} -gt 0 ]
  then  git commit -m "${DATE}: ${1}"
  else  git commit -m "${DATE}: Regular Commit"
  fi
  printf "\n"
}

GIT_PUSH () {
  printf "${PB}\n# Pushing Git Files\n${PB}\n"
  git push
  printf "\n"
}

GIT_PUSH_ALL () {
  GIT_ADD
  GIT_COMMIT "${1}"
  GIT_PUSH
}

GIT_CLONE () {
  if    [ ${#1} -gt 0 ]
  then  git clone --recursive "${1}"
  else  git clone -h
  fi
}
