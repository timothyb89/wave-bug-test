#!/bin/bash

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

NAMESPACE=${NAMESPACE:-"default"}
KUBECTL=${KUBECTL:-"kubectl"}
NAME=${NAME:-"test"}
WAIT=${WAIT:-"0"}

BOLD='\e[1m'
DIM='\e[2m'
RED='\033[0;31m'
NC='\033[0m' 

echo 'versions'
echo '--------'
$KUBECTL version

echo

apply() {
  "$DIR/templates/template.sh" | $KUBECTL -n "$NAMESPACE" apply --prune=true -l "app=$NAME" -f -
  sleep 2
  $KUBECTL -n "$NAMESPACE" get secret,deployment
}

echo "before"
echo "------"
apply

if [[ "$WAIT" -gt 0 ]]; then
  echo "waiting $WAIT seconds..."
  sleep "$WAIT"
fi

echo
echo 'after'
echo '-----'
DEPLOYMENT=false apply

set +e
$KUBECTL -n "$NAMESPACE" get secret "$NAME" > /dev/null 2>&1
if [ $? -ne 0 ]; then
  printf "${RED}ERROR: secret $NAME is missing!${NC}\n" >&2
  exit 1
fi

echo
