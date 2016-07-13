_file_candidates() {
    if git ls-files --error-unmatch &>/dev/null; then
        echo 'git ls-files;GIT>'
    else
        echo 'find . -type f -maxdepth 3 -not -path "*.git*" -not -path "*node_modules*";FIND>'
    fi
}

_dir_candidates() {
    if git ls-files --error-unmatch &>/dev/null; then
        echo 'git ls-files | sed "s|/[^/]*$|/|" | grep ".*/$" | sort | uniq;GIT>'
    else
        echo 'find . -type d -maxdepth 3 -not -path "*.git*" -not -path "*node_modules*" | uniq;FIND>'
    fi

}

p () {
    IFS=';' read command prompt < <(_file_candidates);
    eval $command | $FILTER --prompt=$prompt --query="$1" | xargs $@
}

l() {
    IFS=';' read command prompt < <(_file_candidates);
    local file=$(eval $command | $FILTER --prompt=$prompt --query="$1")
    if [ -n "$file" ]; then
        src-hilite-lesspipe.sh $file | less
    fi
}

d() {
    IFS=';' read command prompt < <(_dir_candidates);
    local dir=$(eval $command | $FILTER --prompt=$prompt --query="$1")
    if [ -n "$dir" ]; then
        cd $dir
    fi
}
