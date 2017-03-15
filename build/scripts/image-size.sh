#!/bin/bash

find ../containers/ -name "*.img" | xargs -I {} du -h {} | awk -F'/|\t' '{ printf "%-15s %-10s %10s\n", $4, $5, $1 }'
