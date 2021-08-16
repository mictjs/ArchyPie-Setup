#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="redream"
rp_module_desc="Redream - Sega Dreamcast Emulator"
rp_module_help="ROM Extensions: .cdi .cue .chd .gdi .iso\n\nCopy your Dreamcast roms to $romdir/dreamcast"
rp_module_licence="PROP"
rp_module_section="exp"
rp_module_flags="noinstclean !all rpi4 !aarch64"

function __binary_url_redream() {
    echo "https://redream.io/download/redream.aarch32-raspberry-linux-latest.tar.gz"
}

function install_bin_redream() {
    downloadAndExtract "$(__binary_url_redream)" "$md_inst"
}

function configure_redream() {
    mkRomDir "dreamcast"

    addEmulator 1 "$md_id" "dreamcast" "$md_inst/redream %ROM%"
    addSystem "dreamcast"

    [[ "$md_mode" == "remove" ]] && return

    chown -R $user:$user "$md_inst"

    local dest="$md_conf_root/dreamcast/redream"
    mkUserDir "$dest"

    # symlinks configs and cache
    moveConfigFile "$md_inst/redream.cfg" "$dest/redream.cfg"
    moveConfigDir "$md_inst/cache" "$dest/cache"
    moveConfigDir "$md_inst/saves" "$dest/saves"
    moveConfigDir "$md_inst/states" "$dest/states"

    # copy / symlink vmus (memory cards)
    local i
    for i in 0 1 2 3; do
      moveConfigFile "$md_inst/vmu$i.bin" "$dest/vmu$i.bin"
    done

    # symlink bios files to libretro core install locations
    mkUserDir "$biosdir/dc"
    ln -sf "$biosdir/dc/dc_boot.bin" "$md_inst/boot.bin"
    ln -sf "$biosdir/dc/dc_flash.bin" "$md_inst/flash.bin"
}
