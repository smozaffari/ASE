#!/bin/bash
# Author: SVM 
# Date: 09/20/16
# Purpose: put together ASE for all of the files. 
# reads from 989_star_overhang_ASE_info - but this file may be too big (submit too many jobs here - consider splitting into two)

setup_log=${scriptName}_${LOGNAME}_${timeTag}.log
echo $setup_log
echo "RUNNING $scriptName as " $(readlink -f $0 ) " on " `date`  | tee  $setup_log

cat 989_star_overhang_ASE_info    | while read i; do
    echo $i
    qsub -v FILE=$i -N $i  /lustre/beagle2/ober/users/smozaffari/ASE/bin/scripts/ASE.pbs 2>&1
    echo -e "qsub -v $FILE=\"$i\" -N \"$i\" /lustre/beagle2/ober/users/smozaffari/ASE/bin/scripts/ASE.pbs"
done

echo "%%%" $(date) "$scriptName completed its execution " | tee -a $setup_log
