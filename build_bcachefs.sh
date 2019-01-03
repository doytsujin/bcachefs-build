#!/bin/bash
# -*- coding: utf-8 -*-
set -e
#apt install kernel-package fakeroot libssl-dev ccache
#apt install libncurses5-dev
#apt install libncursesw5-dev
#apt install libelf-dev

BUILD_DIR="${HOME}/prgsrc"

if [ ! -e "${BUILD_DIR}/bcachefs" ]; then
    git clone https://evilpiepirate.org/git/bcachefs.git "${BUILD_DIR}/bcachefs"
fi

cd "${BUILD_DIR}"/bcachefs/

git fetch origin master
git branch -f master origin/master 2>/dev/null || git reset --hard origin/master
git checkout master
git clean -f

make clean
if [ ! -e .config ]; then
    cp "/boot/config-$(uname -r)" .config
fi
make olddefconfig

./scripts/config --enable BCACHEFS_FS
./scripts/config --enable BCACHEFS_QUOTA
./scripts/config --enable BCACHEFS_POSIX_ACL

./scripts/config --enable LOCALVERSION_AUTO


NPROCS=$(getconf _NPROCESSORS_ONLN)
make -j ${NPROCS} deb-pkg EXTRAVERSION=-bcachefs || exit $?

KERNELVERSION=$(make kernelrelease EXTRAVERSION=-bcachefs)

sudo dpkg -i ../linux-headers-${KERNELVERSION}_${KERNELVERSION}-$(cat .version)_amd64.deb 
sudo dpkg -i ../linux-image-${KERNELVERSION}_${KERNELVERSION}-$(cat .version)_amd64.deb 


############################################################################


if [ ! -e "${BUILD_DIR}/bcachefs-tools" ]; then
    git clone https://evilpiepirate.org/git/bcachefs-tools.git "${BUILD_DIR}/bcachefs-tools"
fi

cd "${BUILD_DIR}/bcachefs-tools"

git fetch origin master
git branch -f master origin/master 2>/dev/null || git reset --hard origin/master
git checkout master
git clean -f

#apt install pkg-config
#apt install libblkid-dev uuid-dev libscrypt-dev libsodium-dev libkeyutils-dev liburcu-dev zlib1g-dev libzstd-dev libattr1-dev libaio-dev liblz4-dev

make clean
make || exit $?
sudo make install

#cd /mnt/bcachefs/