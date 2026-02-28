#!/bin/bash

scontrol show node | awk '

BEGIN {
    RS="NodeName="
}

NR>1 {

    split($1,a," ")
    node=a[1]

    # ---- Lấy RAM FreeMem (MB → GB) ----
    ram_free=0
    if (match($0,/FreeMem=[0-9]+/)) {
        tmp=substr($0,RSTART,RLENGTH)
        split(tmp,x,"=")
        ram_free_mb=x[2]
        ram_free=ram_free_mb/1024   # đổi sang GB
    }

    # ---- Lấy Gres ----
    if (match($0,/Gres=[^\n]*/)) {
        gres_line=substr($0,RSTART+5,RLENGTH-5)
    } else next

    # ---- Lấy AllocTRES ----
    if (match($0,/AllocTRES=[^\n]*/)) {
        alloc_line=substr($0,RSTART+10,RLENGTH-10)
    } else alloc_line=""

    n=split(gres_line,gres_list,",")

    for(i=1;i<=n;i++) {

        if (gres_list[i] ~ /^gpu:/) {

            split(gres_list[i],g,":")
            gpu=g[2]
            total=g[3]

            used=0
            if (match(alloc_line,"gres/gpu:"gpu"=[0-9]+")) {
                tmp=substr(alloc_line,RSTART,RLENGTH)
                split(tmp,x,"=")
                used=x[2]
            }

            free=total-used

            printf "%s %s %d %d %d %.1f\n", gpu,node,total,used,free,ram_free
        }
    }
}
' | sort | awk '

{
    gpu=$1; node=$2; total=$3; used=$4; free=$5; ram=$6

    if (gpu != prev) {
        if (NR>1){
            printf "-----------------------------------------------------------------\n"
            printf "TOTAL %-12s GPU_TOTAL=%d GPU_USED=%d GPU_FREE=%d\n\n", prev, sT, sU, sF
        }
        sT=0; sU=0; sF=0;
        printf "\n========== GPU TYPE: %s ==========\n", gpu
        printf "%-10s %-8s %-8s %-8s %-12s\n", "NODE","TOTAL","USED","FREE","RAM_FREE(GB)"
    }

    printf "%-10s %-8d %-8d %-8d %-12.1f\n", node,total,used,free,ram

    sT+=total
    sU+=used
    sF+=free
    prev=gpu
}
END{
    if(NR>0){
        printf "-----------------------------------------------------------------\n"
        printf "TOTAL %-12s GPU_TOTAL=%d GPU_USED=%d GPU_FREE=%d\n", prev, sT, sU, sF
    }
}
'
