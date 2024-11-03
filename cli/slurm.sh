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
    new)
        bash gpu_new.sh $2 $3
        ;;
    find)
        bash gpu_find.sh $2 $3
        ;;
    *)
        echo "Usage: $0 {info|queue|cancel|new|find}"
        exit 1
        ;;
esac