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

exec ssb-follow --unfollow "${@}"
exit 1

MY_APPNAME='ssb-follow'
MY_AUTHOR='Klaus Alexander Seistrup <klaus@seistrup.dk>'
MY_REVISION='2017-06-27'
MY_VERSION="0.1.0 (${MY_REVISION})"
MY_COPYRIGHT="\
ssb-follow/${MY_VERSION}
Copyright © 2017 ${MY_AUTHOR}

This is free software; see the source for copying conditions. There is no
warranty; not even for merchantability or fitness for a particular purpose.\
"
MY_HELP="
usage: ${ME} [OPTIONS] PUBKEY

options are:
  -h, --help ........ display this help and exit
  -v, --version ..... output version information and exit
  -c, --copyright ... show copying policy and exit
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

my_follow () {
  local contact="${1}"
  shift
  local reason="${*}"
  local json
  local resp

  [[ -z "${contact}" ]] && die 'missing contact'

  if [[ -n "${reason}" ]]; then
    case ${reason} in
      [0-9][0-9][0-9] )
        json="{\"comment\":${reason},\"contact\":\"${contact}\",\"following\":false,\"type\":\"contact\",\"user-agent\":\"sbotc\"}"
      ;;
      * )
        json="{\"comment\":\"${reason}\",\"contact\":\"${contact}\",\"following\":false,\"type\":\"contact\",\"user-agent\":\"sbotc\"}"
      ;;
    esac
  else
    json="{\"contact\":\"${contact}\",\"following\":false,\"type\":\"contact\",\"user-agent\":\"sbotc\"}"
  fi
  #echo "${json}"
  #exit 0
  resp=$(sbotc publish "${json}" 2>&1)

  case "${resp}" in
    '{'*'}' )
      echo "${resp}" \
      | jq .key \
      | tr -d '"'
    ;;
    * )
      die "${resp}"
    ;;
  esac
}

main () {
  local arg="${1}"

  case "${arg}" in
    -h | --help )
      my_help
    ;;
    -v | --version )
      my_version
    ;;
    -c | --copyright )
      my_copyright
    ;;
    -* )
      my_help >&2
      exit 1
    ;;
  esac

  my_follow "${@}"

  exit 0
}

main "${@}"

# eof
