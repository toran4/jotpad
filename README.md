# JotPad

A minimal tabbed temporary-notes application for KDE Plasma 6.

Keep a handful of plain-text scratch pads open while you work — one for commands you're testing, one for a draft message, one for a meeting's running notes. JotPad stays out of your way: no rich text, no sync, no accounts. Just open tabs that remember where you left off.

**Key features:**

- Multiple named tabs, each with its own plain-text area
- Double-click a tab title to rename it inline
- Tabs restore automatically on next launch (persisted via KConfig)
- Closing a tab discards its content immediately — intentional
- Lightweight native Plasma app — fits the KDE desktop without friction

## Tech stack

| Layer | Technology |
|-------|-----------|
| UI | Qt6 / QML / Kirigami |
| Backend | C++17 |
| Persistence | KConfig (KF6) |
| Build | CMake + ECM + Ninja |

---

## Configuration file

Notes are stored in `~/.config/jotpadrc` in KConfig INI format. You can delete this file to start fresh.
