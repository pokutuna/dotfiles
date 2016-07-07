_file_candidates() {
    if git ls-files --error-unmatch &>/dev/null; then
        echo 'git ls-files;GIT>'
    else
        echo 'find . -type f -maxdepth 3 -not -path "*.git*" -not -path "*node_modules*";FIND>'
    fi
}

_dir_candidates() {
    if git ls-files --error-unmatch &>/dev/null; then
        echo 'git ls-files | sed "s|/[^/]*$||" | uniq;GIT>'
    else
        echo 'find . -type d -maxdepth 3 -not -path "*.git*" -not -path "*node_modules*" | uniq;FIND>'
    fi

}

p () {
    IFS=';' read command prompt < <(_file_candidates);
    eval $command | $FILTER --prompt=$prompt | xargs $@
}

l() {
    IFS=';' read command prompt < <(_file_candidates);
    eval $command | $FILTER --prompt=$prompt | xargs -I{} src-hilite-lesspipe.sh {} | less
}

d() {
    IFS=';' read command prompt < <(_dir_candidates);
    local dir=$(eval $command | $FILTER --prompt=$prompt)
    if [ -n "$dir" ]; then
        cd $dir
    fi
}
