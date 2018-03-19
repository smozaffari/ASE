#!/bin/bash
# Script that will be executed on the compute nodes

. /opt/modules/default/init/bash
if [ ! $(module list -t 2>&1 | grep PrgEnv-gnu) ]; then
 module swap PrgEnv-cray PrgEnv-gnu
fi

module load python/2.7.6-vanilla 

FINDIV=$2
SCRIPTDIR=$1

cd $PBS_O_WORKDIR
echo $PBS_O_WORKDIR

cd $FINDIV
echo $PBS_O_WORKDIR/$FINDIV

echo "FINDIV: " $FINDIV

echo "plink-1.9 --bfile /lustre/beagle2/ober/users/smozaffari/POeQTL/results/gexp/paternal_imputed_gexp --keep ${FINDIV}1.txt --geno 0 --recode transpose --out ${FINDIV}1"
plink-1.9 --bfile /lustre/beagle2/ober/users/smozaffari/POeQTL/results/gexp/paternal_imputed_gexp --keep ${FINDIV}1.txt  --geno 0 --recode transpose --out ${FINDIV}1
echo "plink-1.9 --bfile /lustre/beagle2/ober/users/smozaffari/POeQTL/results/gexp/maternal_imputed_gexp --keep ${FINDIV}2.txt --geno 0 --recode transpose --out ${FINDIV}2"
plink-1.9 --bfile /lustre/beagle2/ober/users/smozaffari/POeQTL/results/gexp/maternal_imputed_gexp --keep ${FINDIV}2.txt --geno 0 --recode transpose --out ${FINDIV}2

awk 'NR==FNR{a[$2]==$0;next;} $2 in a{print $0}' ${FINDIV}1.tped ${FINDIV}2.tped > ${FINDIV}2.tped2
awk 'NR==FNR{a[$2]==$0;next;} $2 in a{print $0}' ${FINDIV}2.tped ${FINDIV}1.tped > ${FINDIV}1.tped2


paste <(awk '{print "chr" $1 " " $4 " " $5}' ${FINDIV}1.tped2) <(awk '{print $5}' ${FINDIV}2.tped2) | sed 's/\t/ /g' > ${FINDIV}_SNPs

awk '{if ($3!=$4) print $0}' ${FINDIV}_SNPs > ${FINDIV}_het_SNPs

rm *.tped*
rm *.txt
rm *.tfam
rm *.log
for i in `seq 1 22`
do
   awk -v chr="chr$i" '$1 == chr {print $2 " " $3 " " $4}' ${FINDIV}_het_SNPs > chr${i}.het.snps.txt
   wait
   gzip chr${i}.het.snps.txt
   rm chr${i}.het.snps.txt
done
