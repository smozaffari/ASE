#!/bin/bash

for i in `seq 1 2` 
do
  awk -v snp=$snp -F" " '$1 == "'"$snp"'" {print}' phasedPO_g0.15_AD_gexppl.tped | awk '{for(i=2;i<=NF;i=i+2){printf "%s ", $i}{printf "%s", RS}}' > 'chr'$snp'_phased'
done  
