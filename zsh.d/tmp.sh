mytemp(){
  read YEAR MONTH DAY < <(date '+%Y %m %d')
  TMPDIR="$HOME/mytmp/$YEAR/$MONTH"
  mkdir -p $TMPDIR
  cd `mktemp -d --tmpdir="$TMPDIR" $DAY.$1${1:+.}XXXXXX`
}

mytempd() {
  read YEAR MONTH DAY < <(date '+%Y %m %d')
  TMPDIR="$HOME/mytmp/$YEAR/$MONTH"
  mkdir -p $TMPDIR
  cd $TMPDIR
}
