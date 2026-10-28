#!/usr/bin/env bash
# Freeze the screen, let the user select an area, then pass the capture on.
#   screenshot.sh edit  -> open in swappy
#   screenshot.sh ocr   -> run tesseract, copy text to clipboard
#   screenshot.sh ask   -> choose via notification buttons, or keys while it is
#                          shown (submap "screenshot" in extra.conf):
#                          e/Return = edit, o = ocr, c/Escape = copy.
#                          Dismissed/timed out (8s) -> copy image to clipboard.
#   screenshot.sh choose <edit|ocr|copy>
#                       -> used by those submap keys: records the choice and closes
#                          the pending notification so the waiting "ask" run continues.
# The capture happens while the screen is still frozen; wayfreeze is killed
# before the (slow) follow-up step so the screen unfreezes immediately.

choice="${XDG_RUNTIME_DIR:-/tmp}/screenshot-choice"
notif_id="${XDG_RUNTIME_DIR:-/tmp}/screenshot-notification-id"

if [ "$1" = choose ]; then
  echo "$2" > "$choice"
  gdbus call --session --dest org.freedesktop.Notifications \
    --object-path /org/freedesktop/Notifications \
    --method org.freedesktop.Notifications.CloseNotification "$(cat "$notif_id")" > /dev/null
  exit 0
fi

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
  rm -f "$choice"
  # explicit timeout: noctalia never expires notifications that have actions
  # -p prints the notification id first (saved for "choose"), then the clicked action
  mode="$(notify-send -p -t 8000 -a screenshot -i "$img" -A "edit=(E)dit" -A "ocr=(O)CR" -A "copy=(C)opy" Screenshot |
    { read -r id; echo "$id" > "$notif_id"; cat; })"
  hyprctl -q dispatch submap reset
  [ -n "$mode" ] || mode="$(cat "$choice" 2>/dev/null)"
fi

case "$mode" in
  edit) swappy -f "$img" ;;
  ocr) tesseract "$img" - | wl-copy ;;
  *) wl-copy < "$img" ;;
esac
