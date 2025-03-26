docker images | fzf --exit-0 --multi --header-lines=1 | awk '{ print $3 }' | xargs docker image rm -f
