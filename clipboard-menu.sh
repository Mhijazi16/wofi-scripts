#!/usr/bin/env bash
#
# Clipboard History Manager using Wofi
#
# Requirements: wofi, and either xclip (for X11) or wl-clipboard (for Wayland)
#
# The script saves clipboard content to ~/.cache/clipboard_history.
# When run, it appends new clipboard text (if changed) to the history,
# then opens a Wofi menu to select a previous entry (or clear history).
#

# Determine which clipboard command to use based on the environment.
if [ -n "$WAYLAND_DISPLAY" ]; then
    # On Wayland, use wl-paste and wl-copy
    CLIP_GET="wl-paste"
    CLIP_SET="wl-copy"
else
    # On X11, use xclip
    CLIP_GET="xclip -selection clipboard -o"
    CLIP_SET="xclip -selection clipboard"
fi

# File to store clipboard history
CLIP_HISTORY="$HOME/.cache/clipboard_history"
MAX_HISTORY=500  # Maximum number of history entries to keep

# Ensure the history file and its directory exist
mkdir -p "$(dirname "$CLIP_HISTORY")"
touch "$CLIP_HISTORY"

# Capture current clipboard content
current_clip=$(eval $CLIP_GET 2>/dev/null)

# Debug: Uncomment the following line to see the captured clipboard text
# echo "DEBUG: Current clipboard: [$current_clip]"

# Append to history if not empty and not a duplicate of the last entry
if [ -n "$current_clip" ]; then
    last_entry=$(tail -n 1 "$CLIP_HISTORY")
    if [ "$current_clip" != "$last_entry" ]; then
        echo "$current_clip" >> "$CLIP_HISTORY"
    fi
fi

# Limit the history file to the last MAX_HISTORY lines
history_count=$(wc -l < "$CLIP_HISTORY")
if [ "$history_count" -gt "$MAX_HISTORY" ]; then
    tail -n "$MAX_HISTORY" "$CLIP_HISTORY" > "$CLIP_HISTORY.tmp"
    mv "$CLIP_HISTORY.tmp" "$CLIP_HISTORY"
fi

# Build Wofi options:
# "Clear history" option followed by history entries in reverse order (most recent first)
options="Clear history\n$(tac \"$CLIP_HISTORY\" | sed '/^$/d')"

# Open Wofi menu to select a history entry
selected=$(echo -e "$options" | wofi -d -i -p "Clipboard History")

# Process selection: if "Clear history" is chosen, empty the history file.
if [ "$selected" == "Clear history" ]; then
    > "$CLIP_HISTORY"
    exit 0
fi

# If an entry was selected, copy it back to the clipboard.
if [ -n "$selected" ]; then
    echo -n "$selected" | $CLIP_SET
fi
