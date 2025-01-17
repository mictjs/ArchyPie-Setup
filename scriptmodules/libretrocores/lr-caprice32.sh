#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-caprice32"
rp_module_desc="Amstrad CPC Libretro Core"
rp_module_help="ROM Extensions: .cdt .cpc .dsk\n\nCopy Amstrad CPC Games To: ${romdir}/amstradcpc"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/libretro-cap32/master/cap32/COPYING.txt"
rp_module_repo="git https://github.com/libretro/libretro-cap32 master"
rp_module_section="main"

function sources_lr-caprice32() {
    gitPullOrClone
}

function build_lr-caprice32() {
    make clean
    make
    md_ret_require="${md_build}/cap32_libretro.so"
}

function install_lr-caprice32() {
    md_ret_files=('cap32_libretro.so')
}

function configure_lr-caprice32() {
    mkRomDir "amstradcpc"

    defaultRAConfig "amstradcpc"

    setRetroArchCoreOption "cap32_autorun" "enabled"
    setRetroArchCoreOption "cap32_Model" "6128"
    setRetroArchCoreOption "cap32_Ram" "128"
    setRetroArchCoreOption "cap32_combokey" "y"

    addEmulator 1 "${md_id}" "amstradcpc" "${md_inst}/cap32_libretro.so"

    addSystem "amstradcpc"
}
