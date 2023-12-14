#!/bin/bash
n=$1
beginFolder=$2
gbb=$3

if [[ "$beginFolder" == "Single-Connections"  ]]; then
  types=([0]="normal" [1]="encryption-disabled")
   for type in "${types[@]}";do
      folders=([0]="pprof-cs128-default" [1]="pprof-cs256-default" [2]="pprof-cs128-r50-b50-l50" [3]="pprof-cs256-r50-b50-l50")
      for folder in "${folders[@]}"; do
        rm -r ${beginFolder}/${type}/${folder}/n${n}/Output_noXADS/gb${gbb}/*
        rm -r ${beginFolder}/${type}/${folder}/n${n}/Output_XADS/gb${gbb}/*

    done
  done

  types=([0]="normal" [1]="encryption-disabled")
    for type in "${types[@]}";do
      folders=([0]="pprof-cs128-default" [1]="pprof-cs256-default" [2]="pprof-cs128-r50-b50-l50" [3]="pprof-cs256-r50-b50-l50")
      for folder in "${folders[@]}"; do
        mkdir ${beginFolder}/${type}/${folder}/n${n}
        mkdir ${beginFolder}/${type}/${folder}/n${n}/Output_noXADS
        mkdir ${beginFolder}/${type}/${folder}/n${n}/Output_noXADS/gb${gbb}
        mkdir ${beginFolder}/${type}/${folder}/n${n}/Output_noXADS/gb${gbb}/aes
        mkdir ${beginFolder}/${type}/${folder}/n${n}/Output_noXADS/gb${gbb}/noAES
        mkdir ${beginFolder}/${type}/${folder}/n${n}/Output_noXADS/gb${gbb}/chacha20

        mkdir ${beginFolder}/${type}/${folder}/n${n}/Output_XADS
        mkdir ${beginFolder}/${type}/${folder}/n${n}/Output_XADS/gb${gbb}
        mkdir ${beginFolder}/${type}/${folder}/n${n}/Output_XADS/gb${gbb}/aes
        mkdir ${beginFolder}/${type}/${folder}/n${n}/Output_XADS/gb${gbb}/noAES
        mkdir ${beginFolder}/${type}/${folder}/n${n}/Output_XADS/gb${gbb}/chacha20
      done
    done

else
  types=([0]="normal" [1]="encryption-disabled")
  for type in "${types[@]}";do
    folders=([0]="pprof-cs128-default" [1]="pprof-cs256-default" [2]="pprof-cs128-r50-b50-l50" [3]="pprof-cs256-r50-b50-l50")
    for folder in "${folders[@]}"; do
      rm -r ${beginFolder}/${type}/${folder}/n${n}/*
    done
  done

  types=([0]="normal" [1]="encryption-disabled")
  for type in "${types[@]}";do
    folders=([0]="pprof-cs128-default" [1]="pprof-cs256-default" [2]="pprof-cs128-r50-b50-l50" [3]="pprof-cs256-r50-b50-l50")
    for folder in "${folders[@]}"; do
      mkdir ${beginFolder}/${type}/${folder}/n${n}
      gbs=([0]=1 [1]=2 [2]=5 [3]=10)
      for gb in "${gbs[@]}";do
        mkdir ${beginFolder}/${type}/${folder}/n${n}/Output_noXADS
        mkdir ${beginFolder}/${type}/${folder}/n${n}/Output_noXADS/gb${gb}
        mkdir ${beginFolder}/${type}/${folder}/n${n}/Output_noXADS/gb${gb}/aes
        mkdir ${beginFolder}/${type}/${folder}/n${n}/Output_noXADS/gb${gb}/noAES
        mkdir ${beginFolder}/${type}/${folder}/n${n}/Output_noXADS/gb${gb}/chacha20

        mkdir ${beginFolder}/${type}/${folder}/n${n}/Output_XADS/
        mkdir ${beginFolder}/${type}/${folder}/n${n}/Output_XADS/gb${gb}
        mkdir ${beginFolder}/${type}/${folder}/n${n}/Output_XADS/gb${gb}/aes
        mkdir ${beginFolder}/${type}/${folder}/n${n}/Output_XADS/gb${gb}/noAES
        mkdir ${beginFolder}/${type}/${folder}/n${n}/Output_XADS/gb${gb}/chacha20
        done
    done
  done
fi