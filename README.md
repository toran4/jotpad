# JotPad

A minimal tabbed temporary-notes application for KDE Plasma 6.

- Each tab holds a single plain-text area
- Closing a tab discards its content immediately (no confirmation)
- Closing the app persists all tabs to `~/.config/jotpadrc` via KConfig
- Reopening the app restores tabs in order
- Double-click a tab title to rename it inline

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
