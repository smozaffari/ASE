#!/bin/bash
# Script that will be executed on the compute nodes

. /opt/modules/default/init/bash
if [ ! $(module list -t 2>&1 | grep PrgEnv-gnu) ]; then
 module swap PrgEnv-cray PrgEnv-gnu
fi

export PATH="/lustre/beagle2/ober/users/smozaffari/miniconda2/bin:$PATH"

gene=$1

scriptName=$(basename ${0})
echo $scriptName
scriptName=${scriptName%\.sh}
echo $scriptName

timeTag=$(date "+%y_%m_%d_%H_%M_%S")

grep -w "$gene"  ../ASE_summarystats_v19 | sort | uniq -c > ${gene}_count