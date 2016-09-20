#!/bin/bash
# Author: SVM 

setup_log=${scriptName}_${LOGNAME}_${timeTag}.log
echo $setup_log
echo "RUNNING $scriptName as " $(readlink -f $0 ) " on " `date`  | tee  $setup_log

cat queud | while read i; do
    echo $i
    qsub -v FILE=$i -N $i  /lustre/beagle2/ober/users/smozaffari/ASE/bin/scripts/ASE.pbs 2>&1
    echo -e "qsub -v $FILE=\"$i\" -N \"$i\" /lustre/beagle2/ober/users/smozaffari/ASE/bin/scripts/ASE.pbs"
done

echo "%%%" $(date) "$scriptName completed its execution " | tee -a $setup_log
