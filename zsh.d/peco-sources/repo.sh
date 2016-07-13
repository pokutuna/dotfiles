repo() {
    local selected=$(ghq list -p | $FILTER --query="$1")
    if [ -n "$selected" ]; then
        cd $selected
    fi
}
