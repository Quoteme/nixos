#!/usr/bin/env bash
# Freeze the screen, let the user select an area, then pass the capture on.
#   screenshot.sh edit  -> open in swappy
#   screenshot.sh ocr   -> run tesseract, copy text to clipboard
#   screenshot.sh ask   -> choose edit/ocr via notification buttons
# The capture happens while the screen is still frozen; wayfreeze is killed
# before the (slow) follow-up step so the screen unfreezes immediately.

mode="${1:-edit}"
img="$(mktemp --suffix=.png)"
trap 'rm -f "$img"' EXIT

wayfreeze --after-freeze-cmd "grim -g \"\$(slurp)\" '$img'; pkill -x wayfreeze"

# slurp cancelled (Escape) -> nothing captured
[ -s "$img" ] || exit 0

[ "$mode" = ask ] && mode="$(notify-send -i "$img" -A edit=Edit -A ocr=OCR Screenshot)"

case "$mode" in
  edit) swappy -f "$img" ;;
  ocr) tesseract "$img" - | wl-copy ;;
esac
