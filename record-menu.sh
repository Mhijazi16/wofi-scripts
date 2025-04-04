#!/bin/sh -x

PIC="$(xdg-user-dir PICTURES)/screen_shots_luke"
VID="$(xdg-user-dir VIDEOS)"

get_options() {
  printf "\
📋 Copy Area Screenshot (to clipboard)
📋 Copy Full Screenshot (to clipboard)
🏜️ Save Area Screenshot
🏜️ Save Full Screenshot
🛑 Stop Recording
🎥 + 🎙️ Record Full Video with Mic
🎥 Record Area Video
🎥 Record Full Screen Video
"
}

main() {
  choice=$( (get_options) | wofi -n -d -i)

  case $choice in
    '📋 Copy Area Screenshot (to clipboard)') 
      grim -g "$(slurp)" | wl-copy
      notify-send "Screenshot" "Area screenshot copied to clipboard."
      ;;
    '📋 Copy Full Screenshot (to clipboard)') 
      grim - | wl-copy
      notify-send "Screenshot" "Full screenshot copied to clipboard."
      ;;
    '🏜️ Save Area Screenshot') 
      grim -g "$(slurp)" ${PIC}/$(date +'%s_grim.png') 
      notify-send "Screenshot" "Area screenshot saved."
      ;;
    '🏜️ Save Full Screenshot') 
      grim ${PIC}/$(date +'%s_grim.png') 
      notify-send "Screenshot" "Full screenshot saved."
      ;;
    '🛑 Stop Recording')
      pid=$(pgrep wf-recorder)
      if [ "$pid" ]; then
        pkill --signal SIGINT wf-recorder
        notify-send "Recording" "Recording stopped."
      else
        notify-send "Recording" "No active recording to stop."
      fi
      ;;
    '🎥 Record Area Video') 
      wf-recorder -g "$(slurp)" --file=${VID}/$(date +'%s_vid_selected.mp4')
      notify-send "Video Recording" "Area video recording started."
      ;;
    '🎥 Record Full Screen Video') 
      wf-recorder --file=${VID}/$(date +'%s_vid_full.mp4')
      notify-send "Video Recording" "Full screen video recording started."
      ;;
    '🎥 + 🎙️ Record Full Video with Mic') 
      wf-recorder -a --file=${VID}/$(date +'%s_vid_full_mic.mp4')
      notify-send "Video Recording" "Full screen video with mic recording started."
      ;;
  esac
}

main &

exit 0
