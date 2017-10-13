#!/bin/bash

grep -i "error" ./outputs/log/cwltoil.log | grep -v "yaml.error"
grep -i "failed" ./outputs/log/cwltoil.log | grep -v "completed or totally failed" | grep -v "cmo_gatk.*connect failed"
