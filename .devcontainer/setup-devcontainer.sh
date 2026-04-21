#!/usr/bin/env bash

set -euo pipefail

SDK_ROOT="${ANDROID_SDK_ROOT:-/home/codespace/android-sdk}"
CMDLINE_TOOLS_VERSION="13114758"
CMDLINE_TOOLS_ZIP="commandlinetools-linux-${CMDLINE_TOOLS_VERSION}_latest.zip"
CMDLINE_TOOLS_URL="https://dl.google.com/android/repository/${CMDLINE_TOOLS_ZIP}"
NDK_VERSION="29.0.14206865"
BUILD_TOOLS_VERSION="36.0.0"
PLATFORM_VERSION="android-36"

export ANDROID_SDK_ROOT="${SDK_ROOT}"
export ANDROID_HOME="${SDK_ROOT}"
export PATH="${SDK_ROOT}/cmdline-tools/latest/bin:${SDK_ROOT}/platform-tools:${PATH}"

if command -v sudo >/dev/null 2>&1; then
    SUDO="sudo"
else
    SUDO=""
fi

install_packages() {
    if ! command -v swig >/dev/null 2>&1 || ! command -v unzip >/dev/null 2>&1 || ! command -v curl >/dev/null 2>&1; then
        ${SUDO} apt-get update
        ${SUDO} apt-get install -y curl unzip swig
    fi
}

install_cmdline_tools() {
    if [ ! -x "${SDK_ROOT}/cmdline-tools/latest/bin/sdkmanager" ]; then
        mkdir -p "${SDK_ROOT}/cmdline-tools" /tmp/android-sdk-install
        cd /tmp/android-sdk-install
        curl -L -o cmdline-tools.zip "${CMDLINE_TOOLS_URL}"
        rm -rf "${SDK_ROOT}/cmdline-tools/latest"
        unzip -q cmdline-tools.zip
        mkdir -p "${SDK_ROOT}/cmdline-tools/latest"
        mv cmdline-tools/* "${SDK_ROOT}/cmdline-tools/latest/"
    fi
}

install_android_packages() {
    yes | sdkmanager --licenses >/tmp/android-sdk-licenses.log
    sdkmanager \
        "platform-tools" \
        "platforms;${PLATFORM_VERSION}" \
        "build-tools;${BUILD_TOOLS_VERSION}" \
        "ndk;${NDK_VERSION}"
}

write_local_properties() {
    cat > /workspaces/ics-openvpn/local.properties <<EOF
sdk.dir=${SDK_ROOT}
EOF
}

init_submodules() {
    git -C /workspaces/ics-openvpn submodule update --init --recursive
}

install_packages
install_cmdline_tools
install_android_packages
write_local_properties
init_submodules

echo "Devcontainer setup complete."
