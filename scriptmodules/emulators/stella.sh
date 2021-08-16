#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="stella"
rp_module_desc="Stella - Atari 2600 VCS Emulator"
rp_module_help="ROM Extensions: .a26 .bin .rom .zip .gz\n\nCopy your Atari 2600 roms to $romdir/atari2600"
rp_module_licence="GPL2 https://raw.githubusercontent.com/stella-emu/stella/master/License.txt"
rp_module_repo="git https://github.com/stella-emu/stella.git :_get_branch_stella"
rp_module_section="opt"
rp_module_flags=""

function _get_branch_stella() {
    download https://api.github.com/repos/stella-emu/stella/releases/latest - | grep -m 1 tag_name | cut -d\" -f4
}

function depends_stella() {
    getDepends sdl2 libpng zlib
}

function sources_stella() {
    gitPullOrClone
}

function build_stella() {
    ./configure --prefix="$md_inst"
    make clean
    make
    md_ret_require="$md_build/stella"
}

function install_stella() {
    make install
}

function configure_stella() {
    mkRomDir "atari2600"

    moveConfigDir "$home/.config/stella" "$md_conf_root/atari2600/stella"

    addEmulator 1 "$md_id" "atari2600" "$md_inst/bin/stella -maxres 320x240 -fullscreen 1 -tia.fsfill 1 %ROM%"
    addSystem "atari2600"
}
