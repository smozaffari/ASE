#!/bin/bash

export TMPDIR=$WORKDIR
cd $PBS_O_WORKDIR
export TEMP=$WORKDIR

module load plink

##PO data

#get PO genotypes
plink --bfile /group/ober-resources/resources/Hutterites/PRIMAL/imputed-override3/imputed_cgi.po --keep PO_ids --missing --out phasedPO_AD_gexppl --recode --transpose

#separate by chromosome
for chr in `seq 1 22` 
do
  awk -v chr=$chr -F" " '$1 == "'"$chr"'" {print}' phasedPO_AD_gexppl.tped | awk '{for(i=2;i<=NF;i=i+2){printf "%s ", $i}{printf "%s", RS}}' > 'chr'$chr'_phased'
done

#translate to impute2 haplotype format
perl phased2imputehaps.pl


##regular impute data
plink --bfile /group/ober-resources/resources/Hutterites/PRIMAL/data-sets/qc/qc --keep ../431_Hutt_gexp_ids --out allnotPOgtype --recode 12 --transpose

for chr in `seq 1 22`
do
  awk -v chr=$chr -F" " '$1 == "'"$chr"'" {print}' allnotPOgtype.tped > 'chr'$chr'_gtype'
done

perl impute.pl

