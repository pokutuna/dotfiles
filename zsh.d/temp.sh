temp(){
  read YEAR MONTH DAY < <(date '+%Y %m %d')
  TMPDIR="$HOME/tmp/$YEAR/$MONTH"
  mkdir -p $TMPDIR
  cd `mktemp -d --tmpdir="$TMPDIR" $DAY.$1${1:+.}XXXXXX`
}

tempd() {
  read YEAR MONTH DAY < <(date '+%Y %m %d')
  TMPDIR="$HOME/tmp/$YEAR/$MONTH"
  mkdir -p $TMPDIR
  cd $TMPDIR
}
