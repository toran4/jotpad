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
    # Same CPack flags as package-deb.yml.
    cmake -B "$BUILD_DIR" -G Ninja -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=/usr \
      -DCPACK_GENERATOR=DEB \
      -DCPACK_PACKAGE_VERSION="${VERSION}" \
      -DCPACK_DEBIAN_PACKAGE_SHLIBDEPS=ON \
      -DCPACK_DEBIAN_PACKAGE_MAINTAINER="Tor Andrae <Dmz@andrae.se>" \
      -DCPACK_DEBIAN_PACKAGE_DEPENDS="qml6-module-qtqml, qml6-module-qtquick-controls, qml6-module-qtquick-layouts, qml6-module-org-kde-kirigami" \
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

    export QML_SOURCES_PATHS="$PROJECT_ROOT"
    # Containers have no /dev/fuse, so the AppImage cannot self-mount.
    # ubuntu:26.04 has glibc 2.43, which linuxdeployqt refuses without this flag.
    export APPIMAGE_EXTRACT_AND_RUN=1
    ./linuxdeployqt-continuous-x86_64.AppImage \
      "$APPDIR/usr/share/applications/jotpad.desktop" \
      -appimage \
      -qmake="$(command -v qmake6)" \
      -extra-plugins=platforminputcontexts/libfcitx5platforminputcontextplugin.so \
      -unsupported-allow-new-glibc \
      -verbose=2

    mkdir -p dist
    find . -maxdepth 1 -name '*.AppImage' -exec cp {} dist/ \;
    echo "--- dist ---"; ls -la dist/*.AppImage
    ;;

  *)
    echo "usage: $0 [build|deb|appimage]" >&2
    exit 1
    ;;
esac