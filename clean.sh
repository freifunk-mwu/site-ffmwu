#!/bin/bash

cdir=$(dirname $0)
files=("$cdir/site.conf" "$cdir/site.mk" "$cdir/modules")

for file in ${files[*]}; do
    if [ -f "$file" ]; then
        rm $file
        echo "removed" $file
    fi
done
