#!/bin/bash
# Author: SVM 
# Purpose: copy over RNAseq data and run WASP mapping pipeline
# USAGE: MasterScript.sh <variables> 

inputDir=$(readlink -f $1)
echo "Input files will be searched in " $inputDir

#jobsPerNode=$2 #How many jobs per node = 1..32 what parallel gets 1-32 specific to Beagle
#NNodes=$3 #Number of nodes you want to use /available (for 1000 files, and about 20 jobs/node only need 50 nodes)

#outDir=$(readlink -f $2)

#snpDir=$(readlink -f $3)

#flowcell=$4
#echo $flowcell
NCoresPerNode=32 #notchangeable - beagle

rundir=$PWD
#mkdir -p $OUTDIR

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

#echo "Computation will run on  $NCoresPerNode cores per node " | tee -a $setup_log
#echo "Each python file will be run on " $NNodes " Compute nodes" | tee -a $setup_log
#echo "Total number of python jobs per node will be " $jobsPerNode | tee -a $setup_log

while read gene;
do
    qsub -v GENE=$gene,SCRIPTDIR=$scriptDir -N $gene $scriptDir/second.pbs 2>&1
    echo "qsub -v GENE=\"$gene\",SCRIPTDIR=\"$scriptDir\" -N $gene $scriptDir/second.pbs 2>&1"
done < ../genes.txt

echo "Total number of nodes used will be " $(($count))
echo "%%%" $(date) "$scriptName completed its execution " | tee -a $setup_log
