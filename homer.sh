#!/usr/bin/env bash

src=./dira
dst=./dirb

find "$src/" -type f -print0 |
    while IFS= read -r -d '' file; do
        printf '%s\n' "$file"
    done

# TODO: create links
