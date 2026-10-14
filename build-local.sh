#!/bin/bash
# Reproduce the Ubuntu CI packaging jobs locally, without pushing a tag.
#
#   ./build-local.sh deb       -> package-deb.yml
#   ./build-local.sh appimage  -> package-appimage.yml
#   ./build-local.sh build     -> configure + compile only (fast check)
#
# Intended to be run INSIDE the Ubuntu 26.04 devcontainer
# (.devcontainer/devcontainer.ubuntu.json), which installs the same
# packages as the workflows. Running it on your host will not reproduce
# CI, because the host distros are openSUSE.
#
# version: override with VERSION=1.2.3 (defaults to the git tag, else 0.0.0)
set -euo pipefail

TARGET="${1:-build}"
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_ROOT"

# Mirror the workflows' version resolution.
if [[ -z "${VERSION:-}" ]]; then
  VERSION="$(git describe --tags --exact-match 2>/dev/null || echo 0.0.0)"
  VERSION="${VERSION#v}"
fi

BUILD_DIR="$PROJECT_ROOT/build-ubuntu"

case "$TARGET" in
  build)
    cmake -B "$BUILD_DIR" -G Ninja -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=/usr "$PROJECT_ROOT"
    cmake --build "$BUILD_DIR"
    ;;

  deb)
    # Packaging metadata (maintainer, section, dependencies) lives in
    # CMakeLists.txt; only the generator and version are passed here, exactly
    # like package-deb.yml.
    cmake -B "$BUILD_DIR" -G Ninja -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=/usr \
      -DCPACK_GENERATOR=DEB \
      -DCPACK_PACKAGE_VERSION="${VERSION}" \
      "$PROJECT_ROOT"
    cmake --build "$BUILD_DIR"
    ( cd "$BUILD_DIR" && cpack -G DEB )

    mkdir -p dist
    find "$BUILD_DIR" -name '*.deb' -exec cp {} dist/ \;
    echo "--- dist ---"; ls -la dist/*.deb
    ;;

  appimage)
    APPDIR="$PROJECT_ROOT/appdir"
    rm -rf "$APPDIR" "$PROJECT_ROOT"/*.AppImage

    cmake -B "$BUILD_DIR" -G Ninja -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=/usr "$PROJECT_ROOT"
    cmake --build "$BUILD_DIR"
    DESTDIR="$APPDIR" cmake --install "$BUILD_DIR"
    # Required by -unsupported-allow-new-glibc; see package-appimage.yml.
    mkdir -p "$APPDIR/usr/share/doc/libc6"
    cp /usr/share/doc/libc6/copyright "$APPDIR/usr/share/doc/libc6/copyright"

    if [[ ! -f linuxdeployqt-continuous-x86_64.AppImage ]]; then
      wget -c -q "https://github.com/probonopd/linuxdeployqt/releases/download/continuous/linuxdeployqt-continuous-x86_64.AppImage"
      chmod +x linuxdeployqt-continuous-x86_64.AppImage
    fi

    # VERSION must be exported: without it appimagetool names the AppImage after
    # `git rev-parse --short HEAD` instead of the release version.
    export VERSION
    # Must be a UTF-8 locale, otherwise qmake6 -query emits a locale warning
    # that linuxdeployqt fails to parse, leaving QT_INSTALL_QML empty.
    export LC_ALL=C.UTF-8
    # Containers have no /dev/fuse, so the AppImage cannot self-mount.
    # Extract-and-run is the documented workaround for Docker/CI.
    # ubuntu:26.04 has glibc 2.43, which linuxdeployqt refuses without this flag.
    export APPIMAGE_EXTRACT_AND_RUN=1
    # -qmldir is required because our QML is compiled into the binary's qrc:
    # resource. Without it qmlimportscanner cannot see the imports and no QML
    # module is bundled, so the app aborts with 'module "QtQuick" is not
    # installed'. See package-appimage.yml for the full explanation.
    ./linuxdeployqt-continuous-x86_64.AppImage \
      "$APPDIR/usr/share/applications/jotpad.desktop" \
      -appimage \
      -qmake="$(command -v qmake6)" \
      -qmldir="$PROJECT_ROOT/qml" \
      -extra-plugins=platforminputcontexts/libfcitx5platforminputcontextplugin.so \
      -unsupported-allow-new-glibc \
      -verbose=2

    mkdir -p dist
    # Exclude the linuxdeployqt tool itself: it is also an *.AppImage and sits
    # in the repo root, so a plain glob would copy it into dist/ as well.
    find . -maxdepth 1 -name '*.AppImage' ! -name 'linuxdeployqt-*' \
      -exec cp {} dist/ \;
    echo "--- dist ---"; ls -la dist/*.AppImage
    ;;

  *)
    echo "usage: $0 [build|deb|appimage]" >&2
    exit 1
    ;;
esac