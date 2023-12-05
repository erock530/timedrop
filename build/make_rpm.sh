#!/bin/bash

set -ex

DIR="$(cd $(dirname $BASH_SOURCE)/.. && pwd )"
BIN_DIR="$DIR/bin"
TOOL=$DIR
mkdir -p ${BIN_DIR}
VERSION="${VERSION:-$(grep -e "^Version" ${DIR}/build/timedrop.spec | awk '{print $2}')}"
#VERSION="1.0.0"
#echo "Building programs"
echo "Building Binary Start"
go build -o ${BIN_DIR}/timedrop -ldflags "-X main.Version=${VERSION}${METADATA}" $TOOL/src/server/server.go
echo "Binary Build Complete"


APPVER=$(grep '%define version' ${DIR}/build/timedrop.spec | awk '{print $3}')
APPREV=$(grep '%define version' ${DIR}/build/timedrop.spec | awk '{print $3}' | cut -d. -f3)
APPREL=$(grep '%define release' ${DIR}/build/timedrop.spec | awk '{print $3}')
NEWREV="$(($APPREV + 1))"
NEW_FULL_APPVER="$(echo $APPVER | cut -d. -f1).$(echo $APPVER | cut -d. -f2).$NEWREV"
sed -i "s/%define version.*/%define version $NEW_FULL_APPVER/g" ${DIR}/build/timedrop.spec
APPVER=$NEW_FULL_APPVER
APP_MAJ_MIN_VER="$(echo $APPVER | cut -d. -f1).$(echo $APPVER | cut -d. -f2)"
APP_COMPLETE_VER="$APPVER-$APPREL"

echo " ** Building timedrop v$APP_COMPLETE_VER ($APP_MAJ_MIN_VER)"
mkdir -p ${DIR}/SOURCES/timedrop-$APP_MAJ_MIN_VER
mkdir -p ${DIR}/SOURCES/timedrop-$APP_MAJ_MIN_VER/bin
mkdir -p ${DIR}/SOURCES/timedrop-$APP_MAJ_MIN_VER/man
mkdir -p ${DIR}/SOURCES/timedrop-$APP_MAJ_MIN_VER/etc
mkdir -p ${DIR}/SOURCES/timedrop-$APP_MAJ_MIN_VER/etc/systemd
mkdir -p ${DIR}/SOURCES/timedrop-$APP_MAJ_MIN_VER/etc/systemd/system
mkdir -p ${DIR}/SOURCES/timedrop-$APP_MAJ_MIN_VER/etc/nginx/conf.d

cp -rf ${DIR}/bin/* ${DIR}/SOURCES/timedrop-$APP_MAJ_MIN_VER/bin
cp -rf ${DIR}/man/* ${DIR}/SOURCES/timedrop-$APP_MAJ_MIN_VER/man
cp -rf ${DIR}/build/etc/systemd/system/timedrop.service ${DIR}/SOURCES/timedrop-$APP_MAJ_MIN_VER/etc/systemd/system/timedrop.service
cp -rf ${DIR}/build/etc/nginx/conf.d/timedrop.conf ${DIR}/SOURCES/timedrop-$APP_MAJ_MIN_VER/etc/nginx/conf.d/timedrop.conf

# Build .tar.gz file in SOURCES/
echo "Building .tar.gz ..."
mv ${DIR}/SOURCES/timedrop-$APP_MAJ_MIN_VER ${DIR}/SOURCES/timedrop-$APPVER
tar cf ${DIR}/SOURCES/timedrop.tar -C ${DIR}/SOURCES/ timedrop-$APPVER/
gzip ${DIR}/SOURCES/timedrop.tar


mkdir ${DIR}/RPMS ${DIR}/BUILD ${DIR}/SRPMS
# echo "Building rpm file ..."
rpmbuild -ba ${DIR}/build/timedrop.spec && mv ${DIR}/RPMS/x86_64/timedrop-$APP_MAJ_MIN_VER*rpm .
# Clean up
rm -rf ${DIR}/RPMS ${DIR}/BUILD ${DIR}/SRPMS ${DIR}/SOURCES
