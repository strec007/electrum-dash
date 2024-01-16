#!/bin/bash
set -ev

source contrib/build-wine/docker_env.sh

mkdir -p dist

BUILD_DIR=/root/build
TOR_PROXY_VERSION=0.4.5.8
TOR_PROXY_PATH=https://github.com/pshenmic/tor-proxy/releases/download
TOR_DIST=dist/tor-proxy-setup.exe

export WINEARCH=win64
export WINEPREFIX=/root/.wine-64
export PYHOME=$WINEPREFIX/drive_c/Python310

ZBARW_PATH=https://github.com/Bertrand256/zbarw/releases/download/20180620
ZBARW_FILE=zbarw-zbarcam-0.10-win64.zip
ZBARW_SHA=7705dfd9a1c4b9d07c9ae11502dbe2dc305d08c884f0825b35d21b312316e162
wget ${ZBARW_PATH}/${ZBARW_FILE}
echo "$ZBARW_SHA  $ZBARW_FILE" > sha256.txt
shasum -a256 -s -c sha256.txt
unzip ${ZBARW_FILE} && rm ${ZBARW_FILE} sha256.txt

rm ${TOR_DIST}
TOR_FILE=${TOR_PROXY_VERSION}/tor-proxy-${TOR_PROXY_VERSION}-win64-setup.exe
wget -O ${TOR_DIST} ${TOR_PROXY_PATH}/${TOR_FILE}
TOR_SHA=62ee4604a788ceffb169c368efc9ccf751dce6ae5c2093858a42e814a1bd3c62
echo "$TOR_SHA  $TOR_DIST" > sha256.txt
shasum -a256 -s -c sha256.txt
rm sha256.txt

docker run --rm \
    -e WINEARCH=$WINEARCH \
    -e WINEPREFIX=$WINEPREFIX \
    -e PYHOME=$PYHOME \
    -e BUILD_DIR=$BUILD_DIR \
    -v $(pwd):$BUILD_DIR \
    -v $(pwd):$WINEPREFIX/drive_c/electrum-dash \
    -w $BUILD_DIR \
    -t $DOCKER_IMG_BUILD_WINE \
    $BUILD_DIR/contrib/build-wine/build.sh
