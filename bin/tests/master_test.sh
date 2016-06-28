#!/bin/bash
# Author: SVM 

scriptName=$(basename ${0})
echo $scriptName
scriptName=${scriptName%\.sh}
echo $scriptName
scriptDir=$(readlink -f "$(dirname "$0")")
echo $scriptDir

timeTag=$(date "+%y_%m_%d_%H_%M_%S")

setup_log=${scriptName}_${LOGNAME}_${timeTag}.log
echo $setup_log
echo "RUNNING $scriptName as " $(readlink -f $0 ) " on " `date`  | tee  $setup_log

#genes=19919
genes=10
jobs=$((genes/50))
j=1

while [ $j -lt $genes ]; do
    echo "The counter is $j" | tee -a $setup_log
    echo "qsub -v NUM=$j -N ${j}_test $scriptDir/test_beagle.pbs 2>&1" | tee -a $setup_log
    qsub -v NUM=$j -N ${j}_test $scriptDir/test_beagle.pbs 2>&1
    let j=j+32
done

