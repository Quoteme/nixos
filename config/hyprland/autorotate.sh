#!/usr/bin/env bash
# Rotate the internal screen.
#   autorotate.sh <0-3>     set the transform (called through iio-hyprland/hyprctl)
#   autorotate.sh restore   re-apply the last transform (after a reload or resume)
#
# Hyprland 0.56 treats a transform change as a "soft" monitor update and does not
# recompute the logical size, so bars and windows keep the landscape dimensions.
# Mode changes do recompute it, so portrait requests a minimally different refresh
# rate: Hyprland picks the closest real mode, i.e. the same 60 Hz one for both.
#
# While rotated, titlebars are shown on tiled windows too (tiled-no-bar rule off).
set -uo pipefail

output=eDP-1
landscape_mode=1920x1200@60 # keep in sync with the monitor rule in extra.conf
portrait_mode=1920x1200@60.1
state="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/autorotate"

case "${1:-}" in
  [0-3]) transform=$1 ;;
  restore)
    [ -r "$state" ] || exit 0
    transform=$(<"$state")
    [[ "$transform" == [0-3] ]] || exit 0
    ;;
  *)
    echo "usage: ${0##*/} <0-3>|restore" >&2
    exit 2
    ;;
esac

mode=$landscape_mode
((transform % 2)) && mode=$portrait_mode
no_bar=false
((transform == 0)) && no_bar=true

hyprctl --batch "\
  keyword monitor $output,$mode,auto,1.0,transform,$transform ;\
  keyword input:touchdevice:transform $transform ;\
  keyword input:tablet:transform $transform ;\
  keyword windowrule[tiled-no-bar]:enable $no_bar" >/dev/null
echo "$transform" >"$state"
