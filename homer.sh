#!/usr/bin/env bash
set -e
set -o pipefail

src=./dira
dst=./dirb

find "$src/" -type f -printf '%P\0' |
    while IFS= read -r -d '' file; do
        printf '%s\n' "$file"
    done

# TODO: create links
