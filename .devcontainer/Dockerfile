FROM opensuse/tumbleweed:latest

# Keep the image fresh
RUN zypper --non-interactive refresh && \
    zypper --non-interactive update

# ── Build tools ───────────────────────────────────────────────────────────────
RUN zypper --non-interactive install --no-recommends \
    cmake \
    ninja \
    gcc-c++ \
    git \
    gdb \
    clang \
    clang-tools \
    python3 \
    which \
    make

# ── Qt6 base ──────────────────────────────────────────────────────────────────
RUN zypper --non-interactive install --no-recommends \
    qt6-base-devel \
    qt6-declarative-devel \
    qt6-quickcontrols2-devel \
    qt6-tools \
    qt6-tools-linguist

# ── KDE Frameworks 6 ─────────────────────────────────────────────────────────
RUN zypper --non-interactive install --no-recommends \
    kf6-extra-cmake-modules \
    kf6-kconfig-devel \
    kf6-kcoreaddons-devel \
    kf6-ki18n-devel \
    kf6-kirigami-devel \
    kf6-qqc2-desktop-style

# ── Runtime deps for running inside the container (virtual display) ───────────
RUN zypper --non-interactive install --no-recommends \
    xvfb-run \
    libxcb-icccm4 \
    libxcb-image0 \
    libxcb-keysyms1 \
    libxcb-randr0 \
    libxcb-render-util0 \
    libxcb-xinerama0 \
    libxcb-xkb1 \
    libxkbcommon-x11-0 \
    Mesa-libGL1 \
    Mesa-dri \
    kf6-breeze-icons

# Create a non-root user and workspace directory
RUN useradd -m -s /bin/bash developer && \
    mkdir -p /workspaces && \
    chown developer:developer /workspaces
USER developer
WORKDIR /home/developer

