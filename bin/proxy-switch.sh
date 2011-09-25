
proxy='http://proxy.ksc.kwansei.ac.jp:8080'

apply_proxy()
{
  export http_proxy=$1
  export ALL_PROXY=$1
}


if [ -n "$http_proxy" ]; then
    echo 'unset proxy'
    apply_proxy ""
else
    echo 'set proxy'
    apply_proxy $proxy
fi
