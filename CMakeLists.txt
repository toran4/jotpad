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

qt_add_qml_module(jotpad
    URI "JotPad"
    VERSION 1.0
    QML_FILES
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
