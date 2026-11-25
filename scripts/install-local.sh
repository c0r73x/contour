#!/bin/sh
# Installs the build-local.sh build (out/local) as /Applications/contour.app (macOS) and restarts the
# daemon service on it, so the daemon runs the same build as its clients.
#
# Restarting the daemon ends every shell its windows show: run this when nothing there needs keeping.
# Windows still open then lose their connection; close them and open new ones.
set -eu

here=$(cd "$(dirname "$0")/.." && pwd)
app="${BUILD_DIR:-$here/out/local}/src/contour/contour.app"
dest=/Applications/contour.app

[ -x "$app/Contents/MacOS/contour" ] || { echo "no build at $app (run scripts/build-local.sh)" >&2; exit 1; }

echo "stopping daemon"
"$dest/Contents/MacOS/contour" daemon-service stop || true

echo "installing $app -> $dest"
rm -rf "$dest.new" "$dest.old"
ditto "$app" "$dest.new"
codesign --force --deep --sign - "$dest.new"
mv "$dest" "$dest.old"
mv "$dest.new" "$dest"
rm -rf "$dest.old"

# The config template may name keys only this build knows.
if command -v yadm >/dev/null 2>&1; then
    yadm alt
fi

echo "starting daemon"
"$dest/Contents/MacOS/contour" daemon-service start
"$dest/Contents/MacOS/contour" --version 2>/dev/null || true
