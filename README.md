# JotPad

A minimal tabbed temporary-notes application for KDE Plasma 6.

Keep a handful of plain-text scratch pads open while you work — one for commands you're testing, one for a draft message, one for a meeting's running notes. JotPad stays out of your way: no rich text, no sync, no accounts. Just open tabs that remember where you left off.

**Key features:**

- Multiple named tabs, each with its own plain-text area
- Double-click a tab title to rename it inline
- Tabs restore automatically on next launch (persisted via KConfig)
- Closing a tab discards its content immediately — intentional
- Lightweight native Plasma app — fits the KDE desktop without friction


## Installation

### openSUSE Tumbleweed

A prebuilt RPM package is available on the [releases page](https://github.com/toran4/jotpad/releases). Download the `.rpm` file and install it with:

```bash
sudo zypper install jotpad-*.rpm
```

### Build from source

**Dependencies:** Qt6, KDE Frameworks 6 (Kirigami, KConfig, KI18n, KCoreAddons), CMake, Ninja, and a C++17 compiler. Install these using your distro's package manager, then:

```bash
cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=Release
cmake --build build
sudo cmake --install build
```

---

## Configuration file

Notes are stored in `~/.config/jotpadrc` in KConfig INI format. You can delete this file to start fresh.
