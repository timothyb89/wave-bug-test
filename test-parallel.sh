#!/bin/bash

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

export NAMESPACE=${NAMESPACE:-"default"}
export KUBECTL=${KUBECTL:-"kubectl"}
export NAME=${NAME:-"test"}

COUNT=${COUNT:-"25"}

pids=""

for (( i=0; i<$COUNT; i++ )); do
  NAME="$NAME-$i" "$DIR/test.sh" >/dev/null &

  pids+=" $!"
done

failures=0
total=0

for p in $pids; do
  if ! wait "$p"; then
    failures=$((failures + 1))
  fi

  total=$((total + 1))
done

echo "total: $total"
echo "failures: $failures"
