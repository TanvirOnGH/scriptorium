#!/bin/sh

for dir in */; do
  if [ -d "$dir/.git" ]; then
    (
      cd "$dir" &&
        git add . &&
        git commit -m "$1" &&
        git push
    )
  fi
done
