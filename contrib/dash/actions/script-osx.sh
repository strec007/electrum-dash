#!/bin/bash
set -ev

export MACOSX_DEPLOYMENT_TARGET=10.13
echo osx build version is $DASH_ELECTRUM_VERSION

virtualenv -p python3 env
source env/bin/activate
PIP_CMD="pip"

$PIP_CMD install --no-warn-script-location \
    -r contrib/deterministic-build/requirements.txt
$PIP_CMD install --no-warn-script-location \
    -r contrib/deterministic-build/requirements-hw.txt
$PIP_CMD install --no-warn-script-location \
    -r contrib/deterministic-build/requirements-binaries-mac.txt
$PIP_CMD install --no-warn-script-location x11_hash>=1.4
$PIP_CMD install --no-warn-script-location \
    -r contrib/deterministic-build/requirements-build-mac.txt

export PATH="/usr/local/opt/gettext/bin:$PATH"
./contrib/make_locale
find . -name '*.po' -delete
find . -name '*.pot' -delete

cp contrib/osx/osx_actions.spec osx.spec
cp contrib/dash/pyi_runtimehook.py .
cp contrib/dash/pyi_tctl_runtimehook.py .

pyinstaller --clean \
    -y \
    --name electrum-dash-$DASH_ELECTRUM_VERSION.bin \
    osx.spec

sudo hdiutil create -fs HFS+ -volname "Dash Electrum" \
    -srcfolder dist/Dash\ Electrum.app \
    dist/Dash-Electrum-$DASH_ELECTRUM_VERSION-macosx.dmg
