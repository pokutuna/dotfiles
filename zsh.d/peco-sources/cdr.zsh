peco-cdr () {
    local selected_dir=$(cdr -l | awk '{ print $2 }' | $FILTER --query="$LBUFFER")
    zle redisplay
    if [ -n "$selected_dir" ]; then
        BUFFER="cd ${selected_dir}"
        zle accept-line
    fi
}
zle -N peco-cdr