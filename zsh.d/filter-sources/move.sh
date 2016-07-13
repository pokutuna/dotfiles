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

# git か find でファイルを選ぶ
f() {
    IFS=';' read command prompt < <(_file_candidates);
    eval $command | $FILTER --prompt=$prompt --query="$1"
}

# ファイルを選んでコマンドに渡す
# $ p cat
p() {
    f | xargs $@
}

# ファイルを選んで emacsclient で開く
pec() {
    f $1 | xargs emacsclient -n
}

# ファイルを選んで syntax highligt 付き less で開く
l() {
    IFS=';' read command prompt < <(_file_candidates);
    local file=$(eval $command | $FILTER --prompt=$prompt --query="$1")
    if [ -n "$file" ]; then
        src-hilite-lesspipe.sh $file | less
    fi
}

# ディレクトリを選んで移動する
d() {
    IFS=';' read command prompt < <(_dir_candidates);
    local dir=$(eval $command | $FILTER --prompt=$prompt --query="$1")
    if [ -n "$dir" ]; then
        cd $dir
    fi
}
