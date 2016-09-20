#!/bin/bash
#Author: SVM

setup_log=${scriptName}_${LOGNAME}_${timeTag}.log
echo $setup_log
echo "RUNNING $scriptName as " $(readlink -f $0 ) " on " `date`  | tee  $setup_log


cut -f1-4 -d" " star_overhang/FlowCell1/4972/4972_lane_6_ASE_info | grep -v D7LYM | sort -k1.4,1n -k2,2n -t" " | uniq -c | grep -v indel | grep -v some >4972_lane6_POreads