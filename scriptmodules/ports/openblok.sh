#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="openblok"
rp_module_desc="OpenBlok: A Block Dropping Game"
rp_module_licence="GPL3 https://raw.githubusercontent.com/mmatyas/openblok/master/LICENSE.md"
rp_module_repo="git https://github.com/mmatyas/openblok :_get_branch_openblok"
rp_module_section="exp"
rp_module_flags=""

function _get_branch_openblok() {
    download "https://api.github.com/repos/mmatyas/openblok/releases/latest" - | grep -m 1 tag_name | cut -d\" -f4
}

function depends_openblok() {
    local depends=(
        'cmake'
        'gettext'
        'ninja'
        'sdl2_image'
        'sdl2_mixer'
        'sdl2_ttf'
        'sdl2'
    )
    getDepends "${depends[@]}"
}

function sources_openblok() {
    gitPullOrClone

    # Fix GCC12 Build Error
    sed -i "1i#include <iterator>" "${md_build}/src/system/InputConfigFile.cpp"
}

function build_openblok() {
    cmake . \
        -B"build" \
        -G"Ninja" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN="ON" \
        -DCMAKE_BUILD_TYPE="Release" \
        -DCMAKE_INSTALL_PREFIX="${md_inst}" \
        -DINSTALL_PORTABLE="ON" \
        -Wno-dev
    ninja -C build clean
    ninja -C build
    md_ret_require="${md_build}/build/src/${md_id}"
}

function install_openblok() {
    ninja -C build install/strip
}

function configure_openblok() {
    moveConfigDir "${home}/.local/share/${md_id}" "${md_conf_root}/${md_id}"

    if [[ "${md_mode}" == "install" ]]; then
        local config
        config="$(mktemp)"

        iniConfig " = " "" "${config}"
        echo "[system]" > "${config}"
        iniSet "fullscreen" "on"

        copyDefaultConfig "${config}" "${md_conf_root}/${md_id}/game.cfg"
        rm "${config}"
    fi

    addPort "${md_id}" "${md_id}" "OpenBlok" "${md_inst}/${md_id}"
}
