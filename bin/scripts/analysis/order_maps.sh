#!/bin/bash

<<<<<<< HEAD
for i in `seq 1 11`;
do
grep -w "FlowCell${i}" newqcsorted > FC${i}_mapped
grep FlowCell2 newqcsorted | grep -v 121171 | grep -v 106622 > FC2_mapped
=======
grep -w "FlowCell1" newqcsorted > FC1_mapped
grep FlowCell2 newqcsorted > FC2_mapped
>>>>>>> e1e0a1566c1e475507c35842cd29d8f1224d3700
grep FlowCell3 newqcsorted > FC3_mapped
grep FlowCell4 newqcsorted > FC4_mapped
grep FlowCell5 newqcsorted > FC5_mapped
grep FlowCell6 newqcsorted > FC6_mapped
grep FlowCell7 newqcsorted > FC7_mapped
grep FlowCell8 newqcsorted > FC8_mapped
grep FlowCell9 newqcsorted > FC9_mapped
grep FlowCell10 newqcsorted > FC10_mapped
grep FlowCell11 newqcsorted > FC11_mapped

mkdir map_FC1 map_FC2 map_FC3 map_FC4 map_FC5 map_FC6 map_FC7 map_FC8 map_FC9 map_FC10 map_FC11



for file in `cat FC1_mapped`; do cp "$file" map_FC1/  ; done 
for file in `cat FC2_mapped`; do cp "$file" map_FC2/  ; done 
for file in `cat FC3_mapped`; do cp "$file" map_FC3/  ; done 
for file in `cat FC4_mapped`; do cp "$file" map_FC4/  ; done 
for file in `cat FC5_mapped`; do cp "$file" map_FC5/  ; done 
for file in `cat FC6_mapped`; do cp "$file" map_FC6/  ; done 
for file in `cat FC7_mapped`; do cp "$file" map_FC7/  ; done 
for file in `cat FC8_mapped`; do cp "$file" map_FC8/  ; done 
for file in `cat FC9_mapped`; do cp "$file" map_FC9/  ; done 
for file in `cat FC10_mapped`; do cp "$file" map_FC10/  ; done 
for file in `cat FC11_mapped`; do cp "$file" map_FC11/  ; done 

for i in `seq 1 11`;
do
    echo $i
    sed -n '1~6p' map_FC${i}/* > order_FC_map
    paste FC${i}_mapped order_FC_map | awk '{print $1 $2}' > test
    sed -n '2~6p' map_FC${i}/* > order_FC_map
    paste test order_FC_map | awk '{print $1, $2, $3}' > test2
    sed -n '3~6p' map_FC${i}/* > order_FC_map
    paste test2 order_FC_map | awk '{print $1, $2, $3, $4}' > test
    sed -n '4~6p' map_FC${i}/* > order_FC_map
    paste test order_FC_map | awk '{print $1, $2, $3, $4, $5}' > test2
    sed -n '5~6p' map_FC${i}/* > order_FC_map
    paste test2 order_FC_map | awk '{print $1, $2, $3, $4, $5, $6}' > test
    sed -n '6~6p' map_FC${i}/* > order_FC_map
    paste test order_FC_map | awk '{print $1, $2, $3, $4, $5, $6, $7}' > test2
    cut -f4 -d"/" test2 | sed 's/.sorted.txt/\ /g' > new_FC_${i}
    rm test
    rm test2
done    



