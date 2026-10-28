#!/usr/bin/env bash
# Rebalance all tiled windows on the active workspace (dwindle has no built-in
# equalize): reset every window's split ratio to 1.0, then restore focus.
set -euo pipefail

ws=$(hyprctl -j activeworkspace | jq -r '.id')
active=$(hyprctl -j activewindow | jq -r '.address // empty')

# Hyprland's Lua config: build one Lua chunk and run it with `hyprctl eval`.
lua=$(hyprctl -j clients | jq -r --argjson ws "$ws" '
  .[] | select(.workspace.id == $ws and .floating == false and .fullscreen == 0)
  | "hl.dispatch(hl.dsp.focus({ window = \"address:\(.address)\" })) hl.dispatch(hl.dsp.layout(\"splitratio 1 exact\"))"')

[ -z "$lua" ] && exit 0
[ -n "$active" ] && lua+=" hl.dispatch(hl.dsp.focus({ window = \"address:$active\" }))"

hyprctl eval "$lua" >/dev/null
