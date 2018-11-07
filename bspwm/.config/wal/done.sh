#!/bin/sh

# ===================
# ====== bspwm ======
# ===================

# Source the colors from wal
source "${HOME}/.cache/wal/colors.sh"

# Set the border colors
bspc config normal_border_color   "$color1"
bspc config active_border_color   "$color2"
bspc config focused_border_color  "$color15"
bspc config presel_feedback_color "$color1"

# =================================================
# Symlink config files so programs can be started
# without referencing the cache directly
#
# Includes: zathura, termite, dunst
# =================================================

mkdir -p  "${HOME}/.config/zathura"
mkdir -p  "${HOME}/.config/termite"
mkdir -p  "${HOME}/.config/dunst"
mkdir -p  "${HOME}/.config/kitty"
ln -sf    "${HOME}/.cache/wal/zathurarc"  "${HOME}/.config/zathura/zathurarc"
ln -sf    "${HOME}/.cache/wal/termite"    "${HOME}/.config/termite/config"
ln -sf    "${HOME}/.cache/wal/dunstrc"    "${HOME}/.config/dunst/dunstrc"
ln -sf    "${HOME}/.cache/wal/kitty.conf" "${HOME}/.config/kitty/kitty.conf"

# ===================
# ====== dunst ======
# ===================

# Restart dunst with the new color scheme
pkill dunst
dunst &
