#!/bin/bash

COUNT=${COUNT:-"20"}

for (( i=0; i<$COUNT; i++ )); do
  echo "try $i:"
  echo "-------"
  ./test.sh

  if [ $? -ne 0 ]; then
    echo '!! BUG !!'
    break
  else
    echo "no bug"
  fi

  echo
  echo
done
