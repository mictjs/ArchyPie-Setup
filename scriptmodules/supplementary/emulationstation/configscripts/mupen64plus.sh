#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

function onstart_mupen64plus_joystick() {
    # Write Temp File Header
    echo "; ${DEVICE_NAME}_START " > /tmp/mp64tempconfig.cfg
    echo "[${DEVICE_NAME}]" >> /tmp/mp64tempconfig.cfg
    iniConfig " = " "" "/tmp/mp64tempconfig.cfg"
    iniSet "plugged" "True"
    iniSet "plugin" "2"
    iniSet "mouse" "False"
    iniSet "AnalogDeadzone" "4096,4096"
    iniSet "AnalogPeak" "32768,32768"
    iniSet "Mempak switch" ""
    iniSet "Rumblepak switch" ""
}

function map_mupen64plus_joystick() {
    local input_name="$1"
    local input_type="$2"
    local input_id="$3"
    local input_value="$4"

    local keys
    local dir
    case "${input_name}" in
        up)
            keys=("DPad U")
            dir=("Up")
            ;;
        down)
            keys=("DPad D")
            dir=("Down")
            ;;
        left)
            keys=("DPad L")
            dir=("Left")
            ;;
        right)
            keys=("DPad R")
            dir=("Right")
            ;;
        b)
            keys=("A Button")
            ;;
        y)
            keys=("B Button")
            ;;
        a)
            keys=("C Button D")
            ;;
        x)
            keys=("C Button U")
            ;;
        leftbottom|leftshoulder)
            keys=("L Trig")
            ;;
        rightbottom|rightshoulder)
            keys=("R Trig")
            ;;
        lefttop|lefttrigger)
            keys=("Z Trig")
            ;;
        start)
            keys=("Start")
            ;;
        leftanalogleft)
            keys=("X Axis")
            dir=("Left")
            ;;
        leftanalogright)
            keys=("X Axis")
            dir=("Right")
            ;;
        leftanalogup)
            keys=("Y Axis")
            dir=("Up")
            ;;
        leftanalogdown)
            keys=("Y Axis")
            dir=("Down")
            ;;
        rightanalogleft)
            keys=("C Button L")
            dir=("Left")
            ;;
        rightanalogright)
            keys=("C Button R")
            dir=("Right")
            ;;
        rightanalogup)
            keys=("C Button U")
            dir=("Up")
            ;;
        rightanalogdown)
            keys=("C Button D")
            dir=("Down")
            ;;
        leftthumb)
            keys=("Mempak switch")
            ;;
        rightthumb)
            keys=("Rumblepak switch")
            ;;
        *)
            return
            ;;
    esac

    local key
    local value
    iniConfig " = " "" "/tmp/mp64keys.cfg"
    for key in "${keys[@]}"; do
        # Read Key Value Axis Takes Two Key/Axis Values
        iniGet "${key}"
        case "${input_type}" in
            axis)
                # Key 'X/Y Axis' Needs Different Button Naming
                if [[ "${key}" == *Axis* ]]; then
                    # If There Is Already A '-'' Axis Add '+'' Axis Value
                    if   [[ "${ini_value}" == *\(* ]]; then
                        value="${ini_value}${input_id}+)"
                    # If There Is Already A '+'' Axis Add '-'' Axis Value
                    elif [[ "${ini_value}" == *\)* ]]; then
                        value="axis(${input_id}-,${ini_value}"
                    # If There Is No 'ini_value' Add '+'' Axis Value
                    elif [[ "${input_value}" == "1" ]]; then
                        value="${input_id}+)"
                    else
                        value="axis(${input_id}-,"
                    fi
                elif [[ "${input_value}" == "1" ]]; then
                    value="axis(${input_id}+) ${ini_value}"
                else
                    value="axis(${input_id}-) ${ini_value}"
                fi
                ;;
            hat)
                if [[ "${key}" == *Axis* ]]; then
                    if   [[ "${ini_value}" == *\(* ]]; then
                        value="${ini_value}${dir})"
                    elif [[ "${ini_value}" == *\)* ]]; then
                        value="hat(${input_id} ${dir} ${ini_value}"
                    elif [[ "${dir}" == "Up" || "${dir}" == "Left" ]]; then
                        value="hat(${input_id} ${dir} "
                    elif [[ "${dir}" == "Right" || "${dir}" == "Down" ]]; then
                        value="${dir})"
                    fi
                else
                    if [[ -n "${dir}" ]]; then
                        value="hat(${input_id} ${dir}) ${ini_value}"
                    fi
                fi
                ;;
            *)
                if [[ "${key}" == *Axis* ]]; then
                    if   [[ "${ini_value}" == *\(* ]]; then
                        value="${ini_value}${input_id})"
                    elif [[ "${ini_value}" == *\)* ]]; then
                        value="button(${input_id},${ini_value}"
                    elif [[ "${dir}" == "Up" || "${dir}" == "Left" ]]; then
                        value="button(${input_id},"
                    elif [[ "${dir}" == "Right" || "${dir}" == "Down" ]]; then
                        value="${input_id})"
                    fi
                else
                    value="button(${input_id}) ${ini_value}"
                fi
                ;;
        esac

        iniSet "${key}" "${value}"
    done
}

function onend_mupen64plus_joystick() {
    local bind
    local axis
    local axis_neg
    local axis_pos
    for axis in "X Axis" "Y Axis"; do
        if [[ "${axis}" == *X* ]]; then
            axis_neg="DPad L"
            axis_pos="DPad R"
        else
            axis_neg="DPad U"
            axis_pos="DPad D"
        fi

        # Analog Stick Sanity Check
        # Replace Axis Values With DPAD Values If There Is No Axis Device Setup
        if ! grep -q "${axis}" /tmp/mp64tempconfig.cfg ; then
            iniGet "${axis_neg}"
            bind=${ini_value//)/,}
            iniGet "${axis_pos}"
            ini_value=${ini_value//axis(/}
            ini_value=${ini_value//hat(/}
            ini_value=${ini_value//button(/}
            bind="${bind}${ini_value}"
            iniSet "$axis" "${bind}"
            iniDel "${axis_neg}"
            iniDel "${axis_pos}"
        fi
    done

    # If There Is No Z Trigger Try To Map The L Shoulder
    # Button To It Via Copying Over The Existing L Trigger
    # Value And Deleting L Trigger After
    if ! grep -q "Z Trig" /tmp/mp64tempconfig.cfg ; then
        iniGet "L Trig"
        iniSet "Z Trig" "${ini_value}"
        iniDel "L Trig"
    fi

    echo "; ${DEVICE_NAME}_END " >> /tmp/mp64tempconfig.cfg
    echo "" >> /tmp/mp64tempconfig.cfg

    # Abort If Old Device Config Cannot Be Deleted
    # Keep Original 'mupen64plus-input-sdl' Configs
    local file="${configdir}/n64/mupen64plus/InputAutoCfg.ini"
    if [[ -f "${file}" ]]; then
        # Backup Current Config File
        cp "${file}" "${file}.bak"
        local escaped_device_name=$(echo "${DEVICE_NAME}" | sed 's|[]\[^$.*/]|\\&|g')
        sed -i /"${escaped_device_name}_START"/,/"${escaped_device_name}_END"/d "${file}"
        if grep -Fq "${DEVICE_NAME}" "${file}" ; then
            rm /tmp/mp64tempconfig.cfg
            return
        fi
    else
        cat > "${file}" << _EOF_
; InputAutoCfg.ini for Mupen64Plus SDL Input plugin

; Keyboard_START
[Keyboard]
plugged = True
plugin = 2
mouse = False
DPad R = key(100)
DPad L = key(97)
DPad D = key(115)
DPad U = key(119)
Start = key(13)
Z Trig = key(122)
B Button = key(306)
A Button = key(304)
C Button R = key(108)
C Button L = key(106)
C Button D = key(107)
C Button U = key(105)
R Trig = key(99)
L Trig = key(120)
Mempak switch = key(44)
Rumblepak switch = key(46)
X Axis = key(276,275)
Y Axis = key(273,274)
; Keyboard_END

_EOF_
    fi

    # Append Temp Device Configuration To InputAutoCfg.ini
    cat /tmp/mp64tempconfig.cfg >> "${file}"
    rm /tmp/mp64tempconfig.cfg
}
