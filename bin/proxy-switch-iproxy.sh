
proxy='http://192.168.1.101:8888'

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
