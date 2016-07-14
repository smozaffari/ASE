#!/bin/bash
# Author: SVM 
# Purpose: loop through RNAseq data and check if genotypes match individual


inputFile=$(readlink -f $1)

jobsPerNode=32
NNodes=31
NCoresPerNode=32
NInputFiles=989
echo "Running all " $NInputFiles " fastq files in $inputFile:" | tee -a $setup_log
filesPerNode=$(( ($NInputFiles+$NNodes-1)/$NNodes))
echo "Running  $filesPerNode bam files per compute node for a total of " $(($filesPerNode*$NNodes))  | tee -a $setup_log


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

nTotSubJobs=0
count=0
FINDIVlist=""
lanelist=""
FClist=""
while read -r line;do
    echo $line;


    FINDIV=$(echo $line | cut -f2 -d".")
    echo $FINDIV

    if [ "$FINDIVlist" ]; then
	FINDIVlist="${FINDIVlist}:${FINDIV}"
    else 
	FINDIVlist=$FINDIV
    fi



    FC=$(echo $line | cut -f1 -d".")
    if [ "$FClist" ]; then
	FClist="${FClist}:${FC}"
    else
	FClist=$FC
    fi

    lane=$(echo $line | cut -f3 -d".")

    if [ "$lanelist" ]; then
	lanelist="${lanelist}:${lane}"
    else
	lanelist=$lane
    fi

    count=$(($count+1))
    nTotSubJobs=$(($nTotSubJobs+1))

    if [ "$count" -eq "$filesPerNode" ] || [ "$nTotSubJobs" -eq "$NInputFiles" ]; then
	echo $count $nTotSubJobs
	echo -e "qsub -v JOBSPERNODE=$jobsPerNode,FINDIV=$FINDIVlist,FC=$FClist,LANE=$lanelist -N ${count}_${nTotSubJobs} $scriptDir/bamid.pbs" | tee -a $setup_log
	qsub -v JOBSPERNODE=$jobsPerNode,FINDIV=$FINDIVlist,FC=$FClist,LANE=$lanelist -N ${count}_${nTotSubJobs} $scriptDir/bamid.pbs
	count=0
	laneList=""
	FClist=""
	lanelist=""
	FINDIVlist=""
    fi


done < $inputFile
