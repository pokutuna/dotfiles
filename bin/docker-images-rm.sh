docker images --format '{{.Repository}}:{{.Tag}}\t{{.Size}}\t{{.ID}}' \
  | fzf --exit-0 --multi --header='TABで複数選択, Enterで確定' \
  | awk '{print $NF}' \
  | xargs docker rmi
