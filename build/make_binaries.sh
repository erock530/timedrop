#!/usr/bin/env bash

set -ex

DIR="$(cd $(dirname $BASH_SOURCE)/.. && pwd )"
BIN_DIR="$DIR/bin"
TIMEDIR=$DIR

mkdir -p ${BIN_DIR}

export $($TIMEDIR/.circleci/semver/version | xargs)

MODULES="
$TIMEDIR/src
"

echo "Building programs"
for module in $MODULES; do
    echo "Building binaries from make_binaries.sh"
        binname=$(basename $module)
	    go build -o ${BIN_DIR}/timedrop -ldflags "-X main.Version=${VERSION}${METADATA}" ${module}
    done
echo "Finished building programs"
