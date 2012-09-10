# http://makimoto.hatenablog.com/#20120505095721
function glitch(){
  sed "s/$2/$3/g" $1 > glitched_$1
  open glitched_$1
}
