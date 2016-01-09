#!/bin/bash
# Script that will be executed on the compute nodes
bamFiles=$1
jobsPerNode=$2
scriptDir=$3
SNP_DIR=$4
WASP=$scriptDir/WASP

plog=$scriptDir/third.log

# functions to be used in the call to parallels
BAM_RUN() {
    python $WASP/mapping/find_intersecting_snps.py -p $1 $SNP_DIR & 
}
export -f BAM_RUN

echo $bamFiles

# Check periodically for activity keep only my processes, once and hour for 20 hours
# to figure out whether we are reasonably load balanced
# NOTE: WHOAMI is exported from calling pbs script
#top -b -d 3600.00 -n 20 -u $WHOAMI >> ${destdir}/topLog.${runStamp} 2>&1 &

parallel -j $jobsPerNode  BAM_RUN ::: $($bamFiles) >>$plog 2>&1 


