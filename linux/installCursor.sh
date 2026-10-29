#!/bin/bash
# Use the Dororo cursor set (dororo/ in the repo) as the mouse cursor theme.
# Converts the Windows .ani files to an Xcursor theme in ~/.icons/dororo with win2xcur.
# Usage: bash linux/installCursor.sh
set -euo pipefail
SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")/../dororo" && pwd)"
THEME="$HOME/.icons/dororo"

# 1. Convert (win2xcur needs ImageMagick's MagickWand)
sudo apt install -y pipx libmagickwand-dev
rm -rf "$THEME"
mkdir -p "$THEME/cursors"
pipx run --spec win2xcur win2xcur "$SRC"/*.ani -o "$THEME/cursors"

# 2. Name every Linux cursor after the Windows role it matches (dororo/dororo-assasin.crs)
link() {
    local file=$1
    shift
    for name in "$@"; do ln -sf "$file" "$THEME/cursors/$name"; done
}
link dororo-normal default left_ptr arrow top_left_arrow left_arrow right_ptr context-menu \
    copy alias dnd-copy dnd-link dnd-ask dnd-none zoom-in zoom-out
link dororo-help help question_arrow whats_this left_ptr_help \
    5c6cd98b3f3ebcb1f9c7f1c204630408 d9ce0ab605698f320427677b458ad60b
link dororo-work progress left_ptr_watch half-busy 00000000000000020006000e7e9ffc3f \
    08e8e1c95fe2fc01f976f1e063a24ccd 3ecb610c1bf2410f44200f48c40d3599
link dororo-busy wait watch
link dororo-prec crosshair cross tcross cross_reverse diamond_cross cell plus
link dororo-text text xterm ibeam vertical-text
link dororo-handW pencil draft
link dororo-unavailable not-allowed no-drop dnd-no-drop forbidden crossed_circle circle \
    03b6e0fcb3499374a867c041f52298f0
link dororo-vertic ns-resize n-resize s-resize row-resize size_ver sb_v_double_arrow v_double_arrow \
    double_arrow top_side bottom_side split_v 00008160000006810000408080010102
link dororo-horizon ew-resize e-resize w-resize col-resize size_hor sb_h_double_arrow h_double_arrow \
    left_side right_side split_h 028006030e0e7ebffc7f7070c0600140
link dororo-d1 nwse-resize nw-resize se-resize size_fdiag bd_double_arrow top_left_corner \
    bottom_right_corner c7088f0f3e6c8088236ef8e1e3e70000
link dororo-d2 nesw-resize ne-resize sw-resize size_bdiag fd_double_arrow top_right_corner \
    bottom_left_corner fcf1c3c7cd4491d801f1e1c78f100000
link dororo-move move all-scroll fleur size_all dnd-move grab grabbing openhand closedhand
link dororo-alt up-arrow up_arrow sb_up_arrow center_ptr
link dororo-link pointer hand hand1 hand2 pointing_hand \
    e29285e634086352946a0e7090d73106 9d800788f1b08800ae810202380a0822

cat > "$THEME/index.theme" <<EOF
[Icon Theme]
Name=Dororo
Comment=Dororo Assasin cursors by HusenPo, public domain
EOF

# 3. Make it the default for the compositor, X apps and GTK apps
mkdir -p ~/.icons/default ~/.config/environment.d
printf '[Icon Theme]\nInherits=dororo\n' > ~/.icons/default/index.theme
printf 'XCURSOR_THEME=dororo\nXCURSOR_SIZE=32\n' > ~/.config/environment.d/cursor.conf
gsettings set org.gnome.desktop.interface cursor-theme dororo 2> /dev/null || true
echo 'Dororo cursors installed: log out and back in to see them everywhere.'
