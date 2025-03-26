gcloud-switch() {
  local selected=$(
    gcloud config configurations list --format='table[no-heading](is_active.yesno(yes="[x]",no="[_]"), name, properties.core.account, properties.core.project.yesno(no="(unset)"))' \
      | $FILTER --select-1 --query="$1" \
      | awk '{print $2}'
  )
  if [ -n "$selected" ]; then
    gcloud config configurations activate $selected
  fi
}
