#!/usr/bin/env bash
#--------------------------
# STRING
#--------------------------
str_join() {
  local array_name=$1
  local _IFS=$IFS
  if [[ $# == 1 ]]; then
    IFS=,
  else
    IFS=${2}
  fi
  eval "printf '%s\\n' \"\${${array_name}[*]:-}\""
  IFS=$_IFS
}

str_lower() {
  local str=${1:-}
  printf '%s\n' "${str,,}"
}

str_upper() {
  local str=${1:-}
  printf '%s\n' "${str^^}"
}

str_startswith() {
  [[ $2${1##"$2"} == "$1" ]]
}

str_endswith() {
  [[ ${1%%"$2"}$2 == "$1" ]]
}

str_index() {
  local string=$1
  local index=$2
  eval echo "\${string:$index:1}"
}

# regex match and return the matched string.
# Arguments: string regex [index=1]
str_match() {
  [[ ${3:-} == 0 ]] && echo "index cannot be 0" >&2 && return 3

  if [[ $1 =~ $2 ]]; then
    if ((${#BASH_REMATCH[@]} > 1)); then
      printf '%s\n' "${BASH_REMATCH[${3:-1}]}"
    else
      echo ''
    fi
  else
    echo ''
  fi
}

str_ltrim() {
  local str=${1:-}
  if (( $# < 2 )); then
    printf '%s\n' "${str#"${str%%[![:space:]]*}"}"
  else
    printf '%s\n' "${str##$2}"
  fi
}

str_rtrim() {
  local str=${1:-}
  if (( $# < 2 )); then
    printf '%s\n' "${str%"${str##*[![:space:]]}"}"
  else
    printf '%s\n' "${str%%$2}"
  fi
}

str_trim() {
  local str=${1:-}
  shift
  str=$(str_rtrim "$str" "$@")
  str_ltrim "$str" "$@"
}

#--------------------------
#        ARRAY
#--------------------------
array_hasitem() {
  local array_name=$1
  local match="$2"
  local item1

  eval "[[ \${#${array_name}[@]} == 0 ]] && return 1"
  eval "for item1 in \"\${${array_name}[@]}\"; do [[ \"\$item1\" == \"\$match\" ]] && return 0; done; return 1"
}

array_append() {
  # append <array name> <item1>
  local array_name=$1
  local item1
  shift
  for item1 in "$@"; do
    eval "${array_name}+=(\"$item1\" )"
  done
}

array_intersection() {
  local array1_name=$1
  local array2_name=$2

  local item1
  local item2
  eval "
  for item1 in \"\${${array1_name}[@]}\"; do
    for item2 in \"\${${array2_name}[@]}\"; do
      [[ \"\$item1\" == \"\$item2\" ]] && {
        echo \"\$item1\"
        break
      }
    done
  done
  "
}

array_echo() {
  local array_name=$1
  eval "printf '%s\\n' \"\${${array_name}[@]:-}\""
}

unique_array_add() {
  local array_name=$1
  local item=$2
  local elem
  for elem in "${!array_name}"; do
    [[ "$elem" == "$item" ]] && return 0
  done
  eval "${array_name}+=(\"$item\" )"
}

#--------------------------
#  ACTION
#--------------------------

askyes() {
  local msg=$1
  local default=${2:-Y}
  local prompt
  if [[ $default == Y ]]; then
    default=0
    prompt='[Y/n]: '
  elif [[ $default == N ]]; then
    default=1
    prompt='[y/N]: '
  else
    echo "Invalid argument 'default'. Valid value is 'Y' and 'N'. Current=${default}" >&2
    return 3
  fi

  local answer
  while true; do
    read -rp "$msg $prompt " answer

    answer=$(str_lower "$answer")
    if [[ $answer =~ ^ye?s?$ ]]; then
      return 0
    elif [[ $answer =~ ^no?$ ]]; then
      return 1
    elif [[ $answer == '' ]]; then
      [[ "$default" -eq 0 ]] && return 0 || return 1
    else
      continue
    fi
  done
}

# ONLY BASH >= 4
if [[ ${BASH_VERSION:0:1} -lt 4 ]]; then
  echo "Bash version should >=4, current is $BASH_VERSION please upgrade your bash." >&2
  return 1
fi

#-----------------
# DICT
#-----------------
# dict_new: declare -A variable=()
dict_put() {
  local dictname="$1"
  local key="$2"
  local value="$3"
  eval "${dictname}['$key']=$value"
}

dict_get() {
  local dictname="$1"
  local key="$2"
  eval "echo \"\${${dictname}['$key']}\""
}

dict_remove() {
  local dictname="$1"
  local key="$2"
  unset "${dictname}['$key']"
}

dict_keys() {
  local item
  eval "for item in "\${!$1[@]}"; do echo "\$item"; done"
}

dict_values() {
  local item
  eval "for item in "\${!$1[@]}"; do echo "\${$1[\$item]}"; done"
}

dict_clear() {
  local item
  eval "for item in "\${!$1[@]}"; do unset "$1[\$item]"; done"
}

dict_echo() {
  local item
  eval "for item in "\${!$1[@]}"; do echo "\$item=\${$1[\$item]}"; done"
}
