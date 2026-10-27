
#!/bin/bash
# Screen recording toggle script for i3
RECORDING_FILE=~/Videos/screen_record_$(date +%F_%T).mp4
PID_FILE=/tmp/screen_record.pid

if [ -f $PID_FILE ]; then
    # Stop recording if the PID file exists
    kill $(cat $PID_FILE)
    rm $PID_FILE
    thunar = ~/Videos/
    notify-send "Screen Recording" "Recording stopped."
else
    # Start recording if not already running
    cd ~/Videos
    # ffmpeg -video_size 1920x1080 -framerate 30 -f x11grab -i :0.0 $RECORDING_FILE &> /dev/null &

# ffmpeg -video_size 1920x1080 -framerate 30 -f x11grab -i :0.0 output.mp4
    ffmpeg -video_size 1920x1080 -framerate 30 -f x11grab -i :0.0 "recording_$(date +\%Y-\%m-\%d_\%H-\%M-\%S).mp4"
    echo $! > $PID_FILE
    notify-send "Screen Recording" "Recording started."
fi
