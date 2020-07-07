#!/bin/bash

CWD=$(cd $(dirname "$0") && pwd)

if [ $# == 0 ]; then
  echo 'localssl.sh {on|off}'
  exit
fi

if [ $1 == 'on' ]; then
  set -x
  docker-compose -f $CWD/localssl/docker-compose.yaml up -d
elif [ $1 == 'off' ]; then
  set -x
  docker-compose -f $CWD/localssl/docker-compose.yaml down
fi
