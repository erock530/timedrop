#!/usr/bin/env bash

set -ex

DIR="$(cd $(dirname $BASH_SOURCE)/.. && pwd )"
BIN_DIR="$DIR/bin"
TOOL=$DIR

mkdir -p ${BIN_DIR}

VERSION="${VERSION:-$(grep -e "^Version" ${DIR}/build/timedrop.spec | awk '{print $2}')}"
#VERSION="1.0.0"

echo "Building programs"
    echo "Building module"
            go build -o ${BIN_DIR}/timedrop -ldflags "-X main.Version=${VERSION}${METADATA}" $TOOL/src/server/server.go
echo "Binary Build Complete"
