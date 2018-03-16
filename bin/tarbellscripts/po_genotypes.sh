#!/bin/bash 


scriptName=$(basename ${0})
scriptName=${scriptName%\.sh}
scriptDir=$(readlink -f "$(dirname "$0")")
echo $scriptDir

timeTag=$(date "+%y_%m_%d_%H_%M_%S")

setup_log=${scriptName}_${LOGNAME}_${timeTag}.log
echo $setup_log
echo "RUNNING $scriptName as " $(readlink -f $0 ) " on " `date`  | tee  $setup_log


while read LINE; do
    echo "$LINE"
    mkdir $LINE
    echo $LINE
    echo "HUTTERITES ${LINE}2" > $LINE/${LINE}2.txt
    echo "HUTTERITES ${LINE}1" > $LINE/${LINE}1.txt
    echo "qsub -v FINDIV=$LINE $scriptDir/geno.pbs"
    qsub -v FINDIV=$LINE $scriptDir/geno.pbs
    sleep 3
done < /group/ober-resources/users/smozaffari/ASE/data/justfindivs
