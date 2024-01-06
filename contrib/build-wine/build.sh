#!/bin/bash

source ./contrib/dash/electrum_dash_version_env.sh;
echo wine build version is $DASH_ELECTRUM_VERSION

./contrib/make_locale

export ELECTRUM_COMMIT_HASH=$(git rev-parse HEAD)
export GCC_TRIPLET_HOST="x86_64-w64-mingw32"
export host_strip="${GCC_TRIPLET_HOST}-strip"

./contrib/build-wine/build_secp256k1.sh
./contrib/build-wine/build_x11_hash.sh

mv $BUILD_DIR/zbarw $WINEPREFIX/drive_c/

cd $WINEPREFIX/drive_c/electrum-dash

rm -rf build
rm -rf dist/electrum-dash

cp contrib/build-wine/deterministic.spec .
cp contrib/dash/pyi_runtimehook.py .
cp contrib/dash/pyi_tctl_runtimehook.py .

wget https://download.lfd.uci.edu/pythonlibs/archived/cp36/multidict-5.1.0-cp36-cp36m-win_amd64.whl
pip install ./multidict-5.1.0-cp36-cp36m-win_amd64.whl

wine python -m pip install --no-dependencies --no-warn-script-location \
    -r contrib/deterministic-build/requirements.txt
wine python -m pip install --no-dependencies --no-warn-script-location \
    -r contrib/deterministic-build/requirements-hw.txt
wine python -m pip install --no-dependencies --no-warn-script-location \
    -r contrib/deterministic-build/requirements-binaries.txt
wine python -m pip install --no-dependencies --no-warn-script-location \
    -r contrib/deterministic-build/requirements-build-wine.txt

wine pyinstaller --clean -y \
    --name electrum-dash-$DASH_ELECTRUM_VERSION.exe \
    deterministic.spec

NSIS_EXE="$WINEPREFIX/drive_c/Program Files (x86)/NSIS/makensis.exe"

wine "$NSIS_EXE" /NOCD -V3 \
    /DPRODUCT_VERSION=$DASH_ELECTRUM_VERSION \
    /DWINEARCH=$WINEARCH \
    contrib/build-wine/electrum-dash.nsi
