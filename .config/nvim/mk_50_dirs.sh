#!/usr/bin/env bash

original_dir="$(pwd)"

for i in {1..50}; do
    mkdir $i
    cd $i
    rand10=$(( ($RANDOM % 10) + 1))
    for j in $(seq 1 $rand10); do
        rand100=$(( ($RANDOM % 1000) + 101))
        touch $rand100
    done
done

cd $original_dir
