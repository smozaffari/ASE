#!/bin/bash
# Script that will be executed on the compute nodes

ASEDIR=$1
NUM=$2
N2=$3

. /opt/modules/default/init/bash
if [ ! $(module list -t 2>&1 | grep PrgEnv-gnu) ]; then
 module swap PrgEnv-cray PrgEnv-gnu
fi


export HOME=/lustre/beagle2/ober/users/smozaffari/ASE/results/tests_flipped/
R_LIBS=/lustre/beagle2/ober/users/smozaffari/R_libs

scriptName=$(basename ${0})
echo $scriptName
scriptName=${scriptName%\.sh}
echo $scriptName

timeTag=$(date "+%y_%m_%d_%H_%M_%S")

setup_log=${scriptName}_${LOGNAME}_${timeTag}.log
echo $setup_log
echo "RUNNING $scriptName as " $(readlink -f $0 ) " on " `date`  | tee  $setup_log


R_shell() {
    Rscript  --verbose  --vanilla /lustre/beagle2/ober/users/smozaffari/ASE/bin/tests/flipped_beagle.R  $1 
  
}
export -f R_shell

parallel -j 32  R_shell ::: $(seq $NUM $N2 )  2>&1