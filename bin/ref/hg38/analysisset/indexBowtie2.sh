#!/bin/bash
#PBS -l mppwidth=32
#PBS -l walltime=05:00:00
#PBS -j oe 
## Beagle specific
##PBS -A CI-MCB000155

cd $PBS_O_WORKDIR
echo $PBS_O_WORKDIR
. /opt/modules/default/init/bash
if [ ! $(module list -t 2>&1 | grep PrgEnv-gnu) ]; then
 module swap PrgEnv-cray PrgEnv-gnu
fi

cat hg38.analysisSet.chroms/* > hg38_all.fa

module load bowtie2/2.1.0 
mkdir bowtie2Index
bowtie2-build hg38_all.fa  bowtie2Index/genome


