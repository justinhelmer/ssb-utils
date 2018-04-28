#!/bin/bash
# -*- mode: sh; coding: utf-8 -*-
ME="${0##*/}"
##############################################################################
# This program is free software; you can redistribute it and/or modify it    #
# under the terms of the GNU General Public License as published by the Free #
# Software Foundation; either version 3 of the License, or (at your option)  #
# any later version.                                                         #
#                                                                            #
# This program is distributed in the hope that it will be useful, but with-  #
# out any warranty; without even the implied warranty of merchantability or  #
# fitness for a particular purpose. See the GNU General Public License for   #
# more details. <http://gplv3.fsf.org/>                                      #
##############################################################################

MY_APPNAME='ssb-post'
MY_AUTHOR='Klaus Alexander Seistrup <klaus@seistrup.dk>'
MY_REVISION='2017-04-19'
MY_VERSION="0.1.1 (${MY_REVISION})"
MY_COPYRIGHT="\
ssb-post/${MY_VERSION}
Copyright © 2017 ${MY_AUTHOR}

This is free software; see the source for copying conditions. There is no
warranty; not even for merchantability or fitness for a particular purpose.\
"
MY_HELP="
usage: ${ME} [OPTIONS] [MESSAGE]

positional arguments:
  MESSAGE ........... message to post

optional arguments are:
  -h, --help ........ display this help and exit
  -v, --version ..... output version information and exit
  --copyright ....... show copying policy and exit
or:
  -c CHANNEL, --channel CHANNEL
                      post to CHANNEL
"

die () {
  [[ -n "${1}" ]] && {
    echo "${ME}:" "${@}" >&2
    exit 1
  }
  exit 0
}

my_help () {
  echo "${MY_HELP}"
}

my_version () {
  echo "${MY_APPNAME}/${MY_VERSION}"
}

my_copyright () {
  echo "${MY_COPYRIGHT}"
}

main () {
  local arg1="${1}"
  local channel="${2}"
  local extra=''
  local message=''
  local result=''

  case "${arg1}" in
    --help | -h )
      my_help
      exit 0
    ;;
    --version | -v )
      my_version
      exit 0
    ;;
    --copyright )
      my_copyright
      exit 0
    ;;
    --channel | -c )
      [[ -z "${channel}" ]] && {
        die 'option ‘--channel’ requires an argument'
      }
      shift 2
      extra="--channel ${channel}"
    ;;
    -* )
      my_help >&2
      exit 1
    ;;
  esac

  if [[ "${#}" -gt 0 ]]; then
    message="${*}"
  else
    message="$(cat)"
  fi

  result=$(sbot publish --type post $extra --text "${message}")

  which jq >/dev/null 2>&1 && {
    echo "${result}" | jq .key | tr -d '"'
  }
  exit 0
}

main "${@}"

# eof
