#!/bin/bash
# Author: Sahar
# 8/23/2016
# Beagle

# PURPOSE: loop through RNAseq data and check if genotypes match individual
# INPUT: file with how RNAseq folders are arranged, including Flowcell and Findiv as a folder and subfolder
# 	 swaps.txt --> lustre/beagle2/ober/users/smozaffari/ASE/results/swaps_genotype/swaps.txt
# 	 file made from rna seq data results folder - want to do each flowcell/lane/person individually 
# 	 these are how my RNA seq files are arranged, by FlowCell/FINDIV/lane (how Darren gave them to me)

# 	 input file ex. 
# 	 FlowCell11.108211.lane_3
# 	 FlowCell11.108211.lane_4
# 	 FlowCell9.108211.lane_5
# 	 FlowCell9.108211.lane_4

inputFile=$(readlink -f $1)


# this will change depending on how many people you are checking.
jobsPerNode=30
NNodes=1
NCoresPerNode=32
NInputFiles=30
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

# extract FINDIV and add to FINDIV list to qsub multiple together
    FINDIV=$(echo $line | cut -f2 -d".")
    echo $FINDIV

    if [ "$FINDIVlist" ]; then
	FINDIVlist="${FINDIVlist}:${FINDIV}"
    else 
	FINDIVlist=$FINDIV
    fi
    
# extract Flowcell and add to list to qsub multiple together
    FC=$(echo $line | cut -f1 -d".")
    if [ "$FClist" ]; then
	FClist="${FClist}:${FC}"
    else
	FClist=$FC
    fi

# same thing for lane
    lane=$(echo $line | cut -f3 -d".")
    if [ "$lanelist" ]; then
	lanelist="${lanelist}:${lane}"
    else
	lanelist=$lane
    fi

    count=$(($count+1))
    nTotSubJobs=$(($nTotSubJobs+1))

# once the number it has read through equals the number of files you wanted to run per node, it will qsub the next one
# also empty the lists to continue
    if [ "$count" -eq "$filesPerNode" ] || [ "$nTotSubJobs" -eq "$NInputFiles" ]; then
	echo $count $nTotSubJobs
	echo -e "qsub -v JOBSPERNODE=$jobsPerNode,FINDIV=$FINDIVlist,FC=$FClist,LANE=$lanelist,COUNT=$nTotSubJobs -N swap1_${nTotSubJobs} $scriptDir/bamid.pbs" | tee -a $setup_log
	qsub -v JOBSPERNODE=$jobsPerNode,FINDIV=$FINDIVlist,FC=$FClist,LANE=$lanelist,COUNT=$nTotSubJobs -N swap1_${nTotSubJobs} $scriptDir/bamid.pbs
	count=0
	laneList=""
	FClist=""
	lanelist=""
	FINDIVlist=""
    fi


done < $inputFile
