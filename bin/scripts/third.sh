#!/bin/bash
# Script that will be executed on the compute nodes
bamFiles=$1
jobsPerNode=$2
scriptDir=$3
export SNP_DIR=$4
export inputDir=$5
num=$6
export WASP=$scriptDir/WASP

scriptName=$(basename ${0})
echo $scriptName
scriptName=${scriptName%\.sh}
echo $scriptName

#timeTag=$(date "+%y_%m_%d_%H_%M_%S")

plog=$PWD/${scriptName}_${LOGNAME}_${num}.log
echo $plog
echo "RUNNING $scriptName as " $(readlink -f $0 ) " on " `date`  | tee  $plog
#plog=$inputDir/python_WASP_$num

echo scriptDir $scriptDir
bamFiles=$(echo $bamFiles | sed 's/::/\ /g')

# functions to be used in the call to parallels
FIND_SNPS() {
    python $WASP/mapping/find_intersecting_snps.py -p $inputDir/$1 $SNP_DIR
}
export -f FIND_SNPS

echo $bamFiles

# Check periodically for activity keep only my processes, once and hour for 20 hours
# to figure out whether we are reasonably load balanced
# NOTE: WHOAMI is exported from calling pbs script
#top -b -d 3600.00 -n 20 -u $WHOAMI >> ${destdir}/topLog.${runStamp} 2>&1 &

parallel -j $jobsPerNode  FIND_SNPS ::: $bamFiles  >>$plog 2>&1 


