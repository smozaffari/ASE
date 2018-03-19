#!/bin/bash
# Author: SVM 
# Purpose: make PO genotype files for hets
# USAGE: bash po_genotypes_3.sh 

#jobsPerNode=$2 #How many jobs per node = 1..32 what parallel gets 1-32 specific to Beagle
#NNodes=$3 #Number of nodes you want to use /available (for 1000 files, and about 20 jobs/node only need 50 nodes)


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
    echo "qsub -v FINDIV=$LINE SCRIPTDIR=$scriptDir -N $LINE $scriptDir/po_genotypes_2.pbs" | tee -a $setup_log
    qsub -v FINDIV=$LINE,SCRIPTDIR=$scriptDir -N $LINE $scriptDir/po_genotypes_2.pbs 2>&1
    sleep 3
done < justfindivs



