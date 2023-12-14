#!/bin/bash

n=$1
user=$2
gb=$3

folderPath="/home/andreea/Documents/BachelorsThesis/Code/qperf-go/results_folder/single-connections"
pprofFolder="/home/andreea/Documents/BachelorsThesis/Code/pprof/Single-Connections"
types=([0]="normal" [1]="encryption-disabled")
for type in "${types[@]}";do
	bandwidths=([0]="pprof-cs128-default" [1]="pprof-cs256-default" [2]="pprof-cs128-r50-b50-l50" [3]="pprof-cs256-r50-b50-l50")
	for bandwidth in "${bandwidths[@]}"; do
	  xadss=([0]="Output_noXADS" [1]="Output_XADS")
	  for xads in "${xadss[@]}"; do
        css=([0]="aes" [1]="noAES" [2]="chacha20")
        for cs in "${css[@]}";do
          for ((i=1; i<=n; i++)); do
            echo "running  cpu-profile $i"
            # shellcheck disable=SC1072
            if [[ "$xads" == "Output_noXADS" ]]; then
              go tool pprof -text --nodefraction 0 -output "$pprofFolder/$type/$bandwidth/n$n/$xads/gb$gb/$cs/${i}-${cs}.txt" "$folderPath/$type/$bandwidth/pprof/n$n/gb$gb/$user/$cs/profile_$user$i"  "$folderPath/$type/$bandwidth/pprof/n$n/gb$gb/$user/$cs/profile_$user$i"
            else
              go tool pprof -text --nodefraction 0 -output "$pprofFolder/$type/$bandwidth/n$n/$xads/gb$gb/$cs/${i}-${cs}.txt" "$folderPath/$type/$bandwidth/pprof/n$n/gb$gb/XADS/$user/$cs/profile_$user$i"  "$folderPath/$type/$bandwidth/pprof/n$n/gb$gb/XADS/$user/$cs/profile_$user$i"
            fi
          done
        done
	  done
	done
done
