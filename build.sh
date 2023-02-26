#!/bin/bash

PURPLE=$(tput setaf 99)
PINK=$(tput setaf 469)
CYAN=$(tput setaf 14)
YELLOW=$(tput setaf 11)
DEFAULT=$(tput sgr0)

function main()
{
  install_depends
  build_lg
}

function install_depends()
{
  lg_depends=(
    "cmake"
    "gcc"
    "libgl"
    "libegl"
    "fontconfig"
    "spice-protocol"
    "make"
    "nettle"
    "pkgconf"
    "binutils"
    "libxi"
    "libxinerama"
    "libxss"
    "libxcursor"
    "libxpresent"
    "libxkbcommon"
    "wayland-protocols"
    "ttf-dejavu"
    "libsamplerate"
    "dkms"
    "linux-headers"
  )

  sudo pacman -S ${lg_depends[@]}
}

function build_lg()
{
  git clone --recursive https://github.com/gnif/LookingGlass.git
  cd LookingGlass
  mkdir client/build
  cd client/build
  cmake ../
  make -j$(nproc)

	cat <<- DOC

		${YELLOW}# Run this command to set the correct permissions for /dev/shm/looking-glass${DEFAULT}
		sudo chown \$USER:\$(grep -m1 "user =" /etc/libvirt/qemu.conf | tr -d ' '\" | cut -d"=" -f2) /dev/shm/looking-glass

		${YELLOW}# Add this to <devices> in your XML file${DEFAULT}
		${CYAN}<shmem ${PURPLE}name=${PINK}"looking-glass"${CYAN}>
		  ${CYAN}<model ${PURPLE}type=${PINK}"ivshmem-plain"${CYAN}/>
		  ${CYAN}<size ${PURPLE}unit=${PINK}'M'${CYAN}>${DEFAULT}32${CYAN}</size>
		${CYAN}</shmem>${DEFAULT}

		${YELLOW}# Run this command after you install looking-glass in your Windows VM${DEFAULT}
		./looking-glass-client -c 127.0.0.1 -p {YOUR-SPICE-PORT}
	DOC
}

main
