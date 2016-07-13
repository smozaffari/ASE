#!/bin/bash
#PBS -l mppwidth=30
#PBS -l walltime=02:00:00
#PBS -j oe 
#PBS -N bamid_$FI
## Beagle specific
#PBS -A CI-MCB000155

cd $PBS_O_WORKDIR
echo $PBS_O_WORKDIR
. /opt/modules/default/init/bash
if [ ! $(module list -t 2>&1 | grep PrgEnv-gnu) ]; then
 module swap PrgEnv-cray PrgEnv-gnu
fi

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


aprun -n 1 -N 1 -d 15 plink-1.9 

aprun -n 1  -N 1  -d 15  /lustre/beagle2/ober/users/smozaffari/verifyBamID/verifyBamID/bin/verifyBamID --vcf Hutterite_sexcheck_kao_correct.vcf --bam /lustre/beagle2/ober/users/smozaffari/ASE/results/star/FlowCell7/160591/160591_lane_7.sorted.bam  --ignoreRG --smID HUTTERITES_160591 --self --verbose --out test_160591_exp160591




