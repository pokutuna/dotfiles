# http://qiita.com/b4b4r07/items/9e1bbffb1be70b6ce033
available () {
    local x candidates
    candidates="$1:"
    while [ -n "$candidates" ]
    do
        x=${candidates%%:*}
        candidates=${candidates#*:}
        if type "$x" >/dev/null 2>&1; then
            echo "$x"
            return 0
        else
            continue
        fi
    done
    return 1
}
