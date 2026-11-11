cmake_minimum_required(VERSION 3.20)
project(jotpad VERSION 1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

# ── Find dependencies ─────────────────────────────────────────────────────────
find_package(ECM 6.0 REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH})

include(KDEInstallDirs)
include(KDECMakeSettings)
include(KDECompilerSettings NO_POLICY_SCOPE)
include(ECMSetupVersion)
include(ECMInstallIcons)

find_package(Qt6 REQUIRED COMPONENTS
    Core
    Widgets
    Qml
    Quick
    QuickControls2
)

find_package(KF6 REQUIRED COMPONENTS
    Config
    CoreAddons
    I18n
    Kirigami
)

# ── Sources + QML module ──────────────────────────────────────────────────────
# qt_add_qml_module attaches the QML files directly to the executable target
add_executable(jotpad
    src/main.cpp
    src/notemodel.cpp
    src/notemodel.h
)

qt_add_resources(jotpad "qml"
    PREFIX "/"
    FILES
        qml/Main.qml
        qml/TabButton.qml
)

target_link_libraries(jotpad PRIVATE
    Qt6::Core
    Qt6::Widgets
    Qt6::Qml
    Qt6::Quick
    Qt6::QuickControls2
    KF6::ConfigCore
    KF6::CoreAddons
    KF6::I18n
)

# ── Translations ──────────────────────────────────────────────────────────────
ki18n_install(po)

# ── Install ───────────────────────────────────────────────────────────────────
install(TARGETS jotpad DESTINATION ${KDE_INSTALL_BINDIR})

ecm_install_icons(ICONS icons/sc-apps-jotpad.svg DESTINATION ${KDE_INSTALL_ICONDIR} THEME hicolor)
install(FILES jotpad.desktop DESTINATION ${KDE_INSTALL_APPDIR})

# ── Packaging (CPack) ─────────────────────────────────────────────────────────
# All packaging metadata lives here so it has a single source of truth. The
# workflows and build-local.sh only pass the generator and the version, which
# is resolved from the git tag at build time.
#
# NOTE: every CPACK_* variable must be set *before* include(CPack), because
# include(CPack) snapshots them into the generator configuration.

set(CPACK_PACKAGE_NAME "jotpad")
set(CPACK_PACKAGE_VENDOR "toran4")
set(CPACK_PACKAGE_CONTACT "34127841+toran4@users.noreply.github.com")
# CPACK_DEBIAN_PACKAGE_MAINTAINER wins over CPACK_PACKAGE_CONTACT and is the
# only one that can carry a display name alongside the address.
set(CPACK_DEBIAN_PACKAGE_MAINTAINER "toran4 <34127841+toran4@users.noreply.github.com>")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "A tabbed temporary notes application")
set(CPACK_PACKAGE_HOMEPAGE_URL "https://github.com/toran4/jotpad")
set(CPACK_DEBIAN_PACKAGE_SECTION "utils")

# Derive the shared-library dependencies from the ELF binaries.
set(CPACK_DEBIAN_PACKAGE_SHLIBDEPS ON)

# QML modules imported by qml/*.qml. These are resolved from the system QML
# import path at *run time* and are therefore invisible to dpkg-shlibdeps, so
# they must be listed explicitly. A missing entry makes the app abort on
# startup, e.g.
#     QQmlApplicationEngine failed to load component
#     qrc:/qml/Main.qml:4:1: module "QtCore" is not installed
# Keep in sync with the `import` statements in qml/Main.qml and qml/TabButton.qml.
# Given as a CMake list; CPackDeb joins it with ", ".
set(CPACK_DEBIAN_PACKAGE_DEPENDS
    qml6-module-qtcore
    qml6-module-qtqml
    qml6-module-qtquick
    qml6-module-qtquick-controls
    qml6-module-qtquick-layouts
    qml6-module-org-kde-kirigami
)

include(CPack)
