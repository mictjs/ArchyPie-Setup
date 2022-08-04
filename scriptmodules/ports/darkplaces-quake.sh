#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="darkplaces-quake"
rp_module_desc="DarkPlaces - Quake Engine"
rp_module_licence="GPL2 https://raw.githubusercontent.com/xonotic/darkplaces/master/COPYING"
rp_module_repo="git https://github.com/xonotic/darkplaces.git div0-stable"
rp_module_section="opt"
rp_module_flags="!mali"

function depends_darkplaces-quake() {
    local depends=(
        'libjpeg-turbo'
        'sdl2'
    )
    isPlatform "videocore" && depends+=('raspberrypi-firmware')
    isPlatform "mesa" && depends+=('mesa')

    getDepends "${depends[@]}"
}

function sources_darkplaces-quake() {
    gitPullOrClone

    local patchs=(
        '01_set_default_config_path.patch'
        '02_makefile_fixes.patch'
    )
    isPlatform "rpi" && patches+=('03_rpi_fixes.patch')

    for patch in "${patchs[@]}"; do
        applyPatch "$md_data/$patch"
    done

    # Comment out problematic invariant qualifier which fails to compile with mesa gles on rpi4
    isPlatform "rpi4" && sed -i 's#^"invariant#"//invariant#' "$md_build/shader_glsl.h"
}

function build_darkplaces-quake() {
    local force_opengl="$1"
    # on the rpi4, we build gles first, and then force an opengl build (which is the default)
    [[ -z "$force_opengl" ]] && force_opengl=0
    local params=(OPTIM_RELEASE="")
    if isPlatform "gles" && [[ "$force_opengl" -eq 0 ]]; then
        params+=(SDLCONFIG_UNIXCFLAGS_X11="-DUSE_GLES2")
        if isPlatform "videocore"; then
            params+=(SDLCONFIG_UNIXLIBS_X11="-L /opt/vc/lib -lbrcmGLESv2")
        else
            params+=(SDLCONFIG_UNIXLIBS_X11="-lGLESv2")
        fi
    fi
    make clean
    make sdl-release "${params[@]}"
    if isPlatform "rpi4" && [[ "$force_opengl" -eq 0 ]]; then
        mv "$md_build/darkplaces-sdl" "$md_build/darkplaces-sdl-gles"
        # revert rpi4 gles change which commented out invariant line from earlier.
        sed -i 's#^"//invariant#"invariant#' "$md_build/shader_glsl.h"
        # rebuild opengl version on rpi4
        build_darkplaces-quake 1
        md_ret_require+=("$md_build/darkplaces-sdl-gles")
    else
        md_ret_require+=("$md_build/darkplaces-sdl")
    fi
}

function install_darkplaces-quake() {
    md_ret_files=(
        'darkplaces.txt'
        'darkplaces-sdl'
        'COPYING'
    )
    isPlatform "rpi4" && md_ret_files+=("darkplaces-sdl-gles")
}

function configure_darkplaces-quake() {
    mkRomDir "ports/quake"

    mkUserDir "$arpiedir/ports"
    mkUserDir "$arpiedir/ports/$md_id"

    if [[ "$md_mode" == "install" ]]; then
        moveConfigDir "$arpiedir/ports/$md_id" "$md_conf_root/quake/$md_id" && \
       _game_data_lr-tyrquake

        local params=(-basedir "$romdir/ports/quake" -game %QUAKEDIR%)
        isPlatform "kms" && params+=("+vid_vsync 1")
        if isPlatform "rpi4"; then
            _add_games_lr-tyrquake "$md_inst/darkplaces-sdl-gles ${params[*]}" && \
            _add_games_lr-tyrquake "$md_inst/darkplaces-sdl ${params[*]}"
        else
            _add_games_lr-tyrquake "$md_inst/darkplaces-sdl ${params[*]}"
        fi
    fi
}
