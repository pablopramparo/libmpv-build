#!/bin/bash
# Builds the LGPL-only libmpv (dev package) for x86_64 Windows with clang.
# Adapted from zhongfly/mpv-winbuild's build.sh (MIT License), simplified to a single target.
set -ex
gitdir=$(pwd)
clang_root=$gitdir/clang_root
srcdir=$gitdir/src_packages
bdir=$gitdir/build64
arch=x86_64

cmake -Wno-dev --fresh -DTARGET_ARCH=$arch-w64-mingw32 -DCOMPILER_TOOLCHAIN=clang \
  -DCMAKE_INSTALL_PREFIX=$clang_root -DMINGW_INSTALL_PREFIX=$bdir/install/$arch-w64-mingw32 \
  -DCLANG_PACKAGES_LTO=ON -DENABLE_CCACHE=ON -DSINGLE_SOURCE_LOCATION=$srcdir \
  -DRUSTUP_LOCATION=$gitdir/install_rustup -G Ninja -H$gitdir -B$bdir

ninja -C $bdir download || true
ninja -C $bdir llvm
ninja -C $bdir llvm-clang
ninja -C $bdir rustup-fullclean
ninja -C $bdir rustup
ninja -C $bdir update
ninja -C $bdir mpv-fullclean
ninja -C $bdir mpv

mkdir -p release
mv $bdir/mpv-dev-lgpl-* release/

# The mpv target leaves a folder; pack it so the workflow has a single archive to publish.
for d in release/mpv-dev-lgpl-*/; do
  [ -d "$d" ] || continue
  (cd release && 7z a -mx=9 "$(basename "$d").7z" "$(basename "$d")/*" >/dev/null)
done
