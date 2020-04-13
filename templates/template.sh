#!/bin/bash

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

name=${NAME:-"test"}
deployment=${DEPLOYMENT:-"true"}

template() {
  path="$DIR/$1"

  sed -e "s/\${name}/${name}/g" "$path"
}

if [[ "$deployment" = "true" ]]; then
  template deployment.yaml
  echo '---'
fi

template secret.yaml
