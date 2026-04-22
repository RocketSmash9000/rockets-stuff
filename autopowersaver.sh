#!/bin/bash

# returns battery percentage without % symbol
percentage=$(upower -i $(upower -e | grep 'BAT') | grep -E "percentage" | sed 's/[^0-9]//g')
status=$(upower -i $(upower -e | grep 'BAT') | grep -m 1 -o "discharging")
tlp_running=$(tlp-status | grep -m 1 -o 'battery')

if [[ percentage -lt 95 && status == "discharging" && tlp_running != 'battery' ]] then
	tlp power-saver
fi