#!/bin/sh

CURRENT_DIR=$(dirname $0)
OUT_FILE=$CURRENT_DIR/brew_info.txt

if [ -e $OUT_FILE ]; then
    rm $OUT_FILE
fi

run_with_log() {
    run_command=$1
    echo "--- ${run_command} ---" >> $OUT_FILE
    $(${run_command} >> $OUT_FILE)
    echo '' >> $OUT_FILE
}

run_with_log 'date -R'
run_with_log 'brew list --versions'
run_with_log 'brew list --pinned'
run_with_log 'brew tap'
