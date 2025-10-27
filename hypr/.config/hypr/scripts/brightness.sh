# !/usr/bin/env sh
direction=$1 # '+' or '-'
monitor_data=$(hyprctl monitors -j)
focused_name=$(echo $monitor_data | jq -r '.[] | select(.focused == true) | .name')

if [ "$focused_name" == "eDP-1" ]; then

# Internal display brightness

  if [ "$direction" == "-" ]; then
    brillo -u 150000 -U 8
  else
    brillo -u 150000 -A 8
  fi
else

# External display brightness

  focused_id=$(echo $monitor_data | jq -r '.[] | select(.focused == true) | .id')
  ddcutil --display=$focused_id setvcp 10 $direction 8
fi
