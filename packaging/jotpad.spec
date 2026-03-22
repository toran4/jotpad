Name:           jotpad
Version:        %{_version}
Release:        1
Summary:        A tabbed temporary notes application
License:        GPL-3.0-or-later
Source0:        %{name}-%{version}.tar.gz

BuildRequires:  cmake >= 3.20
BuildRequires:  ninja
BuildRequires:  gcc-c++
BuildRequires:  extra-cmake-modules >= 6.0
BuildRequires:  cmake(Qt6Core)
BuildRequires:  cmake(Qt6Widgets)
BuildRequires:  cmake(Qt6Qml)
BuildRequires:  cmake(Qt6Quick)
BuildRequires:  cmake(Qt6QuickControls2)
BuildRequires:  cmake(KF6Config)
BuildRequires:  cmake(KF6CoreAddons)
BuildRequires:  cmake(KF6I18n)
BuildRequires:  cmake(KF6Kirigami)

Requires:       kf6-qqc2-desktop-style

%description
JotPad is a tabbed temporary notes application built with Qt6 and
KDE Frameworks 6. Notes are stored per-session in ~/.config/jotpadrc.

%prep
%autosetup

%build
cmake -B build -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=%{_prefix}
cmake --build build

%install
DESTDIR=%{buildroot} cmake --install build

%files
%{_bindir}/jotpad
%{_datadir}/icons/hicolor/*/apps/jotpad*

%changelog
