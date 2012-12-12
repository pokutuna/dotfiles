# http://kimoto.hatenablog.com/entry/2012/12/11/135125
function temp(){ cd `mktemp -d --tmpdir="$HOME/tmp/" \`date +'%Y%m%d'.$1${1:+.}\`XXXXXX` }
