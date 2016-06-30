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
# TODO(akavel): below funcs untested yet
function unmkdir {
    # remove empty dirs, stop at $root
    local root="$1"
    local path="$2"
    while (( ${#path} > ${#root} )); do
        rmdir "$path" || true
        path="$(dirname "$path")"
    done
}

# Create new files
comm -z -13 <( cat lista | sort -z ) \
            <( subtree "$src" ) |
    while IFS= read -r -d '' path; do
        printf "add: %q" $path
        mkdir -p "$(dirname "$dst/$path")"
        ln -s -r "$src/$path" "$dst/$path"
    done
comm -z -23 <( cat lista | sort -z ) \
            <( subtree "$src" ) |
    while IFS= read -r -d '' path; do
        printf "remove: %q" $path
        [ -L "$dst/$path" ] || die "$dst/$path: is not a symbolic link"
        rm "$dst/$path"
        unmkdir "$dst" "$(dirname "$dst/$path")"
    done


