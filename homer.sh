#!/usr/bin/env bash
set -e
set -o pipefail

src=./dira
dst=./dirb

function die {
    echo "$(basename "$0"): $@" >&2
    exit 1
}
function subtree {
    local root="$1"
    find "$root/" -type f -printf '%P\0' |
        sort -z
}

# Create new files
comm -z -13 <( cat lista | sort -z ) \
            <( subtree "$src" ) |
    while IFS= read -r -d '' path; do
        echo "added: [$path]"
    done
comm -z -23 <( cat lista | sort -z ) \
            <( subtree "$src" ) |
    while IFS= read -r -d '' path; do
        echo "removed: [$path]"
    done


find "$src/" -type f -printf '%P\0' |
    while IFS= read -r -d '' path; do
        mkdir -p "$(dirname "$dst/$path")"
        # Create link if target doesn't exist (this is default behavior of ln)
        ln -s -r "$src/$path" "$dst/$path"
    done

