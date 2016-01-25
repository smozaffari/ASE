#!/bin/bash
#PBS -N ph2imp2
#PBS -l walltime=2:00:00:00
#PBS -l nodes=1:ppn=1
#PBS -l mem=4gb
#PBS -e ph2imp2.err
#PBS -o ph2imp2.log
#PBS -M smozaffari@uchicago.edu

export TMPDIR=$WORKDIR
cd $PBS_O_WORKDIR
export TEMP=$WORKDIR

module load plink

##PO data

#get PO genotypes
plink --bfile /group/ober-resources/resources/Hutterites/PRIMAL/imputed-override3/imputed_cgi.po --keep PO_ids --missing --out phasedPO_AD_gexppl --recode 12 --transpose

#separate by chromosome
for snp in `seq 1 22` 
do
  awk -v snp=$snp -F" " '$1 == "'"$snp"'" {print}' phasedPO_AD_gexppl.tped | awk '{for(i=2;i<=NF;i=i+2){printf "%s ", $i}{printf "%s", RS}}' > 'chr'$snp'_phased'
done

#translate to impute2 haplotype format
perl phased2imputehaps.pl




