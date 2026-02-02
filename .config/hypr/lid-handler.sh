#!/usr/bin/env bash

get_external_monitor() {
  hyprctl monitors | grep -oP '^Monitor\s+\K(HDMI-\S+|DP-\S+)' | head -n1
}

EXTERNAL=$(get_external_monitor)

if [[ -n "$EXTERNAL" ]]; then
  if [[ $1 == "open" ]]; then
    hyprctl keyword monitor "eDP-1,1920x1200,2560x0,1.5"
  else
    for i in {1..10}; do
      hyprctl dispatch moveworkspacetomonitor $i "$EXTERNAL" 2>/dev/null
    done
    hyprctl keyword monitor "eDP-1,disable"
  fi
fi
