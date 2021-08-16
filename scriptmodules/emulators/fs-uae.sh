#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="fs-uae"
rp_module_desc="FS-UAE - Commodore Amiga 500, 500+, 600, 1200, CDTV & CD32 Emulator"
rp_module_help="ROM Extension: .adf .adz .dms .ipf .zip .lha .iso .cue .bin\n\nCopy Your Amiga Games to $romdir/amiga\n\nCopy Your CD32 Games to $romdir/cd32\n\nCopy Your CDTV Games to $romdir/cdtv\n\nCopy a required BIOS file (e.g. kick13.rom) to $biosdir."
rp_module_licence="GPL2 https://raw.githubusercontent.com/FrodeSolheim/fs-uae/master/COPYING"
rp_module_repo="file https://fs-uae.net/stable/3.0.5/fs-uae-3.0.5.tar.gz"
rp_module_section="exp"
rp_module_flags="!all !arm x11"

function depends_fs-uae() {
    local depends=(
        'glib2'
        'libmpeg2'
        'libpng' 
        'openal'
        'python'
        'python-lhafile'
        'sdl2'
        'libx11'
        'zlib'
    )
    getDepends "${depends[@]}"
}

function _sources_libcapsimage_fs-uae() {
    gitPullOrClone "https://github.com/FrodeSolheim/capsimg.git" "$md_build"
}

function sources_fs-uae() {
    downloadAndExtract "$md_repo_url" "$md_build" --strip-components 1
    _sources_libcapsimage_fs-uae
}

function _build_libcapsimage_fs-uae() {
    # build libcapsimage
    cd "$md_build/capsimg/CAPSImg"
    chmod a+x ./bootstrap.sh
    ./bootstrap.sh
    ./configure
    make
}

function build_fs-uae() {
    _build_libcapsimage_fs-uae

    # build fs-uae
    cd "$md_build"
    ./configure --prefix="$md_inst"
    CXXFLAGS+="-std=gnu++14 -fpermissive"
    make clean
    make
    md_ret_require="$md_build/fs-uae"
}

function _install_libcapsimage_fs-uae() {
    cd "$md_build/capsimg/CAPSImg"
    cp capsimg.so "$md_inst/Plugins"
}

function install_fs-uae() {
    make install
    _install_libcapsimage_fs-uae
}

function configure_fs-uae() {
    mkRomDir "amiga"
    mkRomDir "cd32"
    mkRomDir "cdtv"

    # copy configuring start script
    mkdir "$md_inst/bin"
    cp "$md_data/fs-uae.sh" "$md_inst/bin"
    chmod +x "$md_inst/bin/fs-uae.sh"

    mkUserDir "$md_conf_root/amiga"
#    mkUserDir "$home/Documents/FS-UAE"
#    mkUserDir "$home/Documents/FS-UAE/Configurations"
#    moveConfigDir "$home/Documents/FS-UAE/Configurations" "$md_conf_root/amiga/fs-uae"

    moveConfigDir "$home/.config/fs-uae" "$configdir/amiga/fs-uae"

    # copy default config file
    local config="$(mktemp)"
    iniConfig " = " "" "$config"
    iniSet "base_dir" "$home/.config/fs-uae"
    iniSet "kickstarts_dir" "$biosdir"
    iniSet "fullscreen" "1"
    iniSet "keep_aspect" "1"
    iniSet "zoom" "full"
    iniSet "fsaa" "0"
    iniSet "scanlines" "0"
    iniSet "floppy_drive_speed" "100"
    copyDefaultConfig "$config" "$md_conf_root/amiga/fs-uae/Default.fs-uae"
    rm "$config"

    addEmulator 0 "$md_id-a500+" "amiga" "$md_inst/fs-uae.sh %ROM% A500+"
    addEmulator 1 "$md_id-a500" "amiga" "$md_inst/fs-uae.sh %ROM% A500"
    addEmulator 0 "$md_id-a600" "amiga" "$md_inst/fs-uae.sh %ROM% A600"
    addEmulator 0 "$md_id-a1200" "amiga" "$md_inst/fs-uae.sh %ROM% A1200"
    addEmulator 1 "$md_id-cd32" "cd32" "$md_inst/fs-uae.sh %ROM% CD32"
    addEmulator 1 "$md_id-cdtv" "cdtv" "$md_inst/fs-uae.sh %ROM% CDTV"
    addSystem "amiga"
    addSystem "cd32"
    addSystem "cdtv"
}
