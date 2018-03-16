#!/bin/bash

# Author: Sahar Mozaffari
# Date: 09/20/17
# Purpose: count genes & snps per file
# reads from 989_star_overhang_ASE_info - but this file may be too big (submit too many jobs here - consider splitting into two)
# Usage: bash ASE_master.sh

setup_log=${scriptName}_${LOGNAME}_${timeTag}.log
echo $setup_log
echo "RUNNING $scriptName as " $(readlink -f $0 ) " on " `date`  | tee  $setup_log

for chr in `seq 9 12 `;
do
    echo $chr
    sort  ASE_info/out_FlowCell${chr}_* | uniq -c > ASE_info_sorted_uniq_FC${chr}
#    awk -v chr=$chr '{if ($3==chr); print $0 }' ASE_summarystats_v19| sort | uniq -c  > chr_${chr}
    cut -f1,2,3,4,6  ASE_info_sorted_uniq_FC${chr} | sort | uniq -c > FC${chr}_Genes    
done

echo "%%%" $(date) "$scriptName completed its execution " | tee -a $setup_log
