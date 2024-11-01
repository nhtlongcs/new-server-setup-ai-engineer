#!/bin/bash

case "$1" in
    info)
        sinfo -eO "CPUs:8,Memory:9,Gres:14,NodeAIOT:16,NodeList:50"
        ;;
    queue)
        squeue -u $USER
        ;;
    cancel)
        scancel -u $USER
        ;;
    *)
        echo "Usage: $0 {info|queue|cancel}"
        exit 1
        ;;
esac