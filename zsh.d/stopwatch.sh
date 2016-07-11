type gdate &>/dev/null && STOPWATCH_CMD='gdate +%s.%N' || STOPWATCH_CMD='date +%s'

stopwatch_on () {
    local name=$1
    eval "STOPWATCH_${name}=\$($STOPWATCH_CMD)"
}

stopwatch_off () {
    local name=$1
    local diff=$(( $(eval $STOPWATCH_CMD) - $(eval echo '$'STOPWATCH_${name}) ))
    printf "$name: %.3f sec\n" $diff >&2
}
