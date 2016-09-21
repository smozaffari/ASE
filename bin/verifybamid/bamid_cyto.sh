#!/bin/bash
#PBS -l mppwidth=64
#PBS -l walltime=02:00:00
#PBS -j oe 
#PBS -N bamid_cyto
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



aprun -n 1  -N 1  -d 15  /lustre/beagle2/ober/users/smozaffari/verifyBamID/bin/verifyBamID --vcf Hutterite_check_cyto_kao.vcf --bam ../star_overhang/FlowCell3/162112/162112_lane_4.sorted.bam   --ignoreRG  --self --verbose --out check_162112_lane4

aprun -n 1  -N 1  -d 15  /lustre/beagle2/ober/users/smozaffari/verifyBamID/bin/verifyBamID --vcf Hutterite_check_cyto_kao.vcf --bam ../star_overhang/FlowCell3/162112/162112_lane_3.sorted.bam   --ignoreRG  --self --verbose --out check_162112_lane3

aprun -n 1  -N 1  -d 15  /lustre/beagle2/ober/users/smozaffari/verifyBamID/bin/verifyBamID --vcf Hutterite_check_cyto_kao.vcf --bam ../star_overhang/FlowCell6/159521/159521_lane_5.sorted.bam   --ignoreRG  --self --verbose --out check_159521_lane5

aprun -n 1  -N 1  -d 15  /lustre/beagle2/ober/users/smozaffari/verifyBamID/bin/verifyBamID --vcf Hutterite_check_cyto_kao.vcf --bam ../star_overhang/FlowCell6/159521/159521_lane_6.sorted.bam   --ignoreRG  --self --verbose --out check_159521_lane6

