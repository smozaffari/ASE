#!/bin/bash
# Author: SVM 
# Date: 09/20/16
# Usage: bash keep_master.sh firsthalf_989_star_overhang_ASE_info
# Usage: bash keep_master.sh lasthalf_989_star_overhang_ASE_info
# too many jobs if do just one

setup_log=${scriptName}_${LOGNAME}_${timeTag}.log
echo $setup_log
echo "RUNNING $scriptName as " $(readlink -f $0 ) " on " `date`  | tee  $setup_log

cat keep_bam | while read i; do
    echo $i
    qsub -v FILE=$i -N $i  /lustre/beagle2/ober/users/smozaffari/ASE/bin/scripts/keep.pbs 2>&1
    echo -e "qsub -v $FILE=\"$i\" -N \"$i\" /lustre/beagle2/ober/users/smozaffari/ASE/bin/scripts/keep.pbs"
done

echo "%%%" $(date) "$scriptName completed its execution " | tee -a $setup_log
