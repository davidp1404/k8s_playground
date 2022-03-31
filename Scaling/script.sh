#!/bin/bash
apt update && apt install -y stress

while true
do
    [ -f "/tmp/stress" ] && stress -c 4 -m 4 --vm-bytes 256M -t 10
    sleep 1
done

