#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-mame2010"
rp_module_desc="MAME 0.139 Libretro Core"
rp_module_help="ROM Extension: .zip\n\nCopy MAME ROMs To: ${romdir}/mame-libretro\nOr\n${romdir}/arcade"
rp_module_licence="NONCOM https://raw.githubusercontent.com/libretro/mame2010-libretro/master/docs/license.txt"
rp_module_repo="git https://github.com/libretro/mame2010-libretro master"
rp_module_section="opt"

function depends_lr-mame2010() {
    getDepends zlib
}

function sources_lr-mame2010() {
    gitPullOrClone
}

function build_lr-mame2010() {
    rpSwap on 750
    make clean
    local params=()
    ! isPlatform "x86" && params+=('VRENDER=soft' 'FORCE_DRC_C_BACKEND=1')
    if isPlatform "arm" || isPlatform "aarch64"; then
        params+=('ARM_ENABLED=1')
    fi
    isPlatform "64bit" && params+=('PTR64=1')
    make "${params[@]}" ARCHOPTS="${CFLAGS}" buildtools
    make "${params[@]}" ARCHOPTS="${CFLAGS}"
    rpSwap off
    md_ret_require="${md_build}/mame2010_libretro.so"
}

function install_lr-mame2010() {
    md_ret_files=('mame2010_libretro.so')
}

function configure_lr-mame2010() {
    local system
    for system in arcade mame-libretro; do
        mkRomDir "${system}"
        defaultRAConfig "${system}"
        addEmulator 0 "${md_id}" "${system}" "${md_inst}/mame2010_libretro.so"
        addSystem "${system}"
    done
}
