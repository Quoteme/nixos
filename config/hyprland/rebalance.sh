#!/usr/bin/env bash
# Rebalance all tiled windows on the active workspace (dwindle has no built-in
# equalize): reset every window's split ratio to 1.0, then restore focus.
# 0.56 has no `splitratio exact`, but deltas clamp to [0.1, 1.9], so
# -5 followed by +0.9 always lands on exactly 1.0.
set -euo pipefail

ws=$(hyprctl -j activeworkspace | jq -r '.id')
active=$(hyprctl -j activewindow | jq -r '.address // empty')

cmds=$(hyprctl -j clients | jq -r --argjson ws "$ws" '
  .[] | select(.workspace.id == $ws and .floating == false and .fullscreen == 0)
  | "dispatch focuswindow address:\(.address); dispatch layoutmsg splitratio -5; dispatch layoutmsg splitratio 0.9;"')

[ -z "$cmds" ] && exit 0
[ -n "$active" ] && cmds+=" dispatch focuswindow address:$active"

hyprctl --batch "$cmds" >/dev/null
