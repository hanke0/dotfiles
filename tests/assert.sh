#!/usr/bin/env bash

RED=$(echo -en "\e[31m")
GREEN=$(echo -en "\e[32m")
NORMAL=$(echo -en "\e[00m")
MAGENTA=$(echo -en "\e[35m")
BOLD=$(echo -en "\e[01m")

log_header() {
  printf "\n${BOLD}${MAGENTA}==========  %s  ==========${NORMAL}\n" "$@" >&2
}

log_success() {
  printf "${GREEN}✔ %s${NORMAL}\n" "$*" >&2
}

log_failure() {
  printf "${RED}✖ %s${NORMAL}\n" "$*" >&2
}

assert_eq() {
  local expected="$1"
  local actual="$2"
  local msg="$3"

  if [ "$expected" != "$actual" ]; then
    log_failure "$expected != $actual :: $msg"
    return 1
  else
    log_success ""
    return 0
  fi
}

assert_true() {
  local condition="$1"

  if ! eval "$condition"; then
    log_failure "$condition return false :: $msg"
    return 1
  else
    log_success ""
    return 0
  fi
}

runtest() {
  local exit_code=0
  log_header "$1"
  for var in $(declare -F); do
    var=$(echo "$var" | cut -d' ' -f3)
    if [[ $var != test* ]]; then
      continue
    fi
    printf "[TEST %s]:: " "$var"
    eval "$var"
    exit_code=$?
  done
  [[ "$exit_code" -eq 0 ]] && return 0 || return 1
}
