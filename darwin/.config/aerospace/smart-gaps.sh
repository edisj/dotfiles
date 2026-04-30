#!/bin/bash

count=$(aerospace list-windows --workspace focused | wc -l)
# is_fullscreen=$(aerospace list-windows --focused --format "%{window-is-fullscreen}")
if [ "$count" -eq 1 ]; then
    aerospace fullscreen --no-outer-gaps on
    # borders active_color=0x1a1d25ff inactive_color=0x1a1d25ff width=10.0
fi
