#!/usr/bin/env bash
set -e
set -o pipefail

src=./dira
dst=./dirb

function err {
    echo "$(basename "$0"): $@" >&2
}
function die {
    err "$@"
    exit 1
}
# tempfile prints path of a newly created temporary file
function tempfile {
    mktemp --suffix=".$$.$(basename "$0")"
}
# unmkdir removes empty dirs from $root down to $path
function unmkdir {
    local root="$1"
    local path="$2"
    while [ ${#path} -gt ${#root} ]; do
        rmdir "$path" || return
        path="$(dirname "$path")"
    done
}
# subtree prints relative paths of all files in $root tree, separated by NUL byte and sorted
function subtree {
    local root="$1"
    find "$root/" -type f -printf '%P\0' |
        sort -z
}

# Create new files
comm -z -13 <( cat lista | sort -z ) \
            <( subtree "$src" ) |
    while IFS= read -r -d '' path; do
        printf "add: %q\n" $path
        mkdir -p "$(dirname "$dst/$path")"
        ln -s -r "$src/$path" "$dst/$path"
    done
comm -z -23 <( cat lista | sort -z ) \
            <( subtree "$src" ) |
    while IFS= read -r -d '' path; do
        printf "remove: %q\n" $path
        [ -L "$dst/$path" ] || die "$dst/$path: is not a symbolic link"
        rm "$dst/$path"
        unmkdir "$dst" "$(dirname "$dst/$path")"
    done


