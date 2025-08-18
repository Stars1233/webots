#!/bin/bash

# Exit when any command fails on CI
if [[ ! -z "$CI" ]]; then
    set -e
fi

if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root"
    exit 1
fi

# Detect the operating system
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
    VERSION_ID=$VERSION_ID
else
    echo "Cannot determine the operating system."
    exit 1
fi

# Function to install packages on Ubuntu
install_ubuntu_packages() {
    alias apt='apt --option="APT::Acquire::Retries=3"'
    apt update
    apt install --yes git cmake swig libglu1-mesa-dev libglib2.0-dev libfreeimage3 libfreetype6-dev libxml2-dev libboost-dev libssh-gcrypt-dev libzip-dev libreadline-dev pbzip2 wget zip unzip python3 python3-pip libopenal-dev

    if [[ $VERSION_ID == "22.04" || $VERSION_ID == "24.04" ]]; then
        apt install --yes libzip4 openssl
    else
        echo "Unsupported Ubuntu version: dependencies may not be completely installed. Only the two latest Ubuntu LTS are supported."
    fi
}

# Function to install packages on Fedora
install_fedora_packages() {
    dnf install -y git cmake swig mesa-libGLU-devel glib2-devel freeimage freetype-devel.x86_64 freetype-devel.i686 glibc-devel.x86_64 glibc-devel.i686 libxml2-devel boost-devel libssh-devel libzip-devel readline-devel pbzip2 wget zip unzip python3 python3-pip openal-soft-devel glm-devel stb-devel
}

# Determine the operating system and call the appropriate function
case "$OS" in
    ubuntu)
        install_ubuntu_packages
        ;;
    fedora)
        install_fedora_packages
        ;;
    *)
        echo "Unsupported operating system: $OS"
        exit 1
        ;;
esac

script_full_path=$(dirname "$0")
$script_full_path/linux_runtime_dependencies.sh
