#!/bin/bash

for i in {1..20}; do
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
