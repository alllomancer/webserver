#!/bin/bash
# ldd-cp is a collection of tools to help fetching code and binaries inside
# of a Dockerfile.

set -o nounset
set -o errexit
set -o pipefail


ldd-cp() {
    [ $# -ge 2 ] || usage
    local path="${!#}"

    command -v ldd > /dev/null || die "FAIL: ldd isn't available in \$PATH."

    mkdir -p "$path"
    for src in "${@:1:($#-1)}"; do
        # Output this binary
        echo "$src"
        # Output paths to libraries that this binary depends on
        ldd "$src" | awk '($2=="=>"){print $3};(substr($1,1,1)=="/"){print $1}' || true
    done | sort -u | xargs -I{} install -D {} "$path/{}"
}



usage() {
    cat <<EOF
Usage: $0 <command> [<options>]

  ldd-cp <src> [<src> ...] <path>             - Copy binaries and deps to <path>

EOF
    exit 1
}

die() {
    # Output my args as individual lines to stderr and exit non-zero
    local line
    for line in "$@"; do
        echo "$line" 1>&2
    done
    exit 1
}

[ $# -ge 1 ] || usage
cmd="$1"
shift
case "$cmd" in
    ldd-cp)              ldd-cp "$@" ;;
    *)                   usage ;;
esac