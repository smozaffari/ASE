#!/bin/bash
# Script that will be executed on the compute nodes

. /opt/modules/default/init/bash
if [ ! $(module list -t 2>&1 | grep PrgEnv-gnu) ]; then
 module swap PrgEnv-cray PrgEnv-gnu
fi

module load python/2.7.6-vanilla 


SCRIPTDIR=$1

cd $PBS_O_WORKDIR
echo $PBS_O_WORKDIR


awk '{print "chr" $1 " " $4 " " $5 " "$6}'  /lustre/beagle2/ober/users/smozaffari/POeQTL/results/gexp/paternal_imputed_gexp.bim > all_SNPs
for i in `seq 1 22`
do
   awk -v chr="chr$i" '$1 == chr {print $2, $3, $4}' all_SNPs > chr${i}.snps.txt
   wait
   gzip chr${i}.snps.txt
   rm chr${i}.snps.txt
done


