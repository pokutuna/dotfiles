## from hitode909 http://d.hatena.ne.jp/hitode909/20110219/1298088499
# gitリポジトリから相対パスでcdする
# function u() {
#     cd ./$(git rev-parse --show-cdup)
#     if [ $# = 1 ]; then
#         cd $1
#     fi
# }

#ホームディレクトリから相対パスでcdする
function h() {
    cd
    if [ $# = 1 ]; then
        cd $1
    fi
}

#上に行く
function up()
{
    to=$(perl -le '$p=$ENV{PWD}."/";$d="/".$ARGV[0]."/";$r=rindex($p,$d);$r>=0 && print substr($p, 0, $r+length($d))' $1)
    if [ "$to" = "" ]; then
        echo "no such file or directory: $1" 1>&2
        return 1
    fi
    cd $to
}
