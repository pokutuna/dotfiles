#!/bin/sh
set -x
docker ps -aq -f 'status=exited' -f 'status=dead' | xargs -I{} docker rm -f {}
docker images -aq -f 'dangling=true' | xargs -I{} docker rmi {}
