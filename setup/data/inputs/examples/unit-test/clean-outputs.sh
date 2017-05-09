#!/bin/bash

# find a directory named 'outputs' and remove them all
find .. -maxdepth 2 -name outputs -type d | xargs -I {} rm -rf {}
