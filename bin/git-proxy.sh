#!/bin/sh
CORKSCREW=`which corkscrew`
$CORKSCREW proxy.ksc.kwansei.ac.jp 8080 $1 $2
