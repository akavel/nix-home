#!/usr/bin/env bash
set -e
set -o pipefail

# FIXME(akavel): set $src and $dst properly
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

# Remember current state of $src in $oldsrc
oldsrc="$( tempfile )"
trap "rm '$oldsrc'" EXIT
subtree "$src" > "$oldsrc"

# TODO(akavel): For safety, verify $dst paths to be potentially removed are all correct links

# FIXME(akavel): if [ $# -eq 0 ]; then nix-env -iA nixos.home; else nix-env "$@"; fi

# Create links to added files
comm -z -13 "$oldsrc" <( subtree "$src" ) |
    while IFS= read -r -d '' path; do
        printf "add: %q\n" $path
        mkdir -p "$(dirname "$dst/$path")"
        ln -s -r "$src/$path" "$dst/$path"
    done
# Remove links to removed files
comm -z -23 "$oldsrc" <( subtree "$src" ) |
    while IFS= read -r -d '' path; do
        printf "remove: %q\n" $path
        if [ ! -L "$dst/$path" ]; then
            err "$dst/$path: is not a symbolic link, refusing to remove"
            continue
        fi
        rm "$dst/$path"
        unmkdir "$dst" "$(dirname "$dst/$path")"
    done


