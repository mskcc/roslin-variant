#!/bin/bash

find /var/tmp/ -name "docker-tar*"  -exec rm {} \;
find /tmp/ -name "sbuild-*"  -exec rm {} \;