#!/bin/bash

# Author: Sahar Mozaffari
# Date: 10/10/17
# Purpose: count number of snps per gene.

setup_log=${scriptName}_${LOGNAME}_${timeTag}.log
echo $setup_log
echo "RUNNING $scriptName as " $(readlink -f $0 ) " on " `date`  | tee  $setup_log

echo "awk '{ print $2,$3,$5}' all_FC_ASE | grep -wf ../data/genes_list2.txt | cut -f3 -d" " | sort | uniq -c  > counted_ASE_gene"
awk '{ print $2,$3,$5}' all_FC_ASE | grep -wf ../data/genes_list2.txt | cut -f3 -d" " | sort | uniq -c  > counted_ASE_gene

echo "%%%" $(date) "$scriptName completed its execution " | tee -a $setup_log
