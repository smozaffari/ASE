#!/bin/bash
#PBS -l mppwidth=32
#PBS -l walltime=05:00:00
#PBS -l mem=30gb
#PBS -j oe 
## Beagle specific
##PBS -A CI-MCB000155

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


cat /lustre/beagle2/ober/users/smozaffari/ASE/bin/ref/hg19/hg19.chroms/* > genome.fa
wait

/lustre/beagle2/ober/users/smozaffari/STAR/STAR-2.5.2a/bin/Linux_x86_64/STAR --runMode genomeGenerate --runThreadN 8 --genomeDir /lustre/beagle2/ober/users/smozaffari/ASE/bin/ref/star/. --genomeFastaFiles genome.fa --sjdbGTFfile /lustre/beagle2/ober/users/smozaffari/ASE/bin/ref/hg19/Annotations/genes.gtf --sjdbOverhang 49



