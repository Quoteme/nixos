#!/usr/bin/env bash
# Freeze the screen, let the user select an area, then pass the capture on.
#   screenshot.sh edit  -> open in swappy
#   screenshot.sh ocr   -> run tesseract, copy text to clipboard
#   screenshot.sh ask   -> choose via notification buttons, or keys while it is
#                          shown (submap "screenshot" in extra.conf):
#                          e/Return = edit, o = ocr, Escape = copy.
#                          Dismissed/timed out (8s) -> copy image to clipboard.
# The capture happens while the screen is still frozen; wayfreeze is killed
# before the (slow) follow-up step so the screen unfreezes immediately.

mode="${1:-edit}"
img="$(mktemp --suffix=.png)"
trap 'rm -f "$img"' EXIT

wayfreeze --after-freeze-cmd "grim -g \"\$(slurp)\" '$img'; pkill -x wayfreeze"

# slurp cancelled (Escape) -> nothing captured
[ -s "$img" ] || exit 0

if [ "$mode" = ask ]; then
  # always leave the submap, even if this script dies, else e/o stay grabbed
  trap 'hyprctl -q dispatch submap reset; rm -f "$img"' EXIT
  hyprctl -q dispatch submap screenshot
  # explicit timeout: noctalia never expires notifications that have actions
  mode="$(notify-send -t 8000 -a screenshot -i "$img" -A edit=Edit -A ocr=OCR -A copy=Copy Screenshot)"
  hyprctl -q dispatch submap reset
fi

case "$mode" in
  edit) swappy -f "$img" ;;
  ocr) tesseract "$img" - | wl-copy ;;
  *) wl-copy < "$img" ;;
esac
