 #!/bin/bash
#PBS -N phase_ped
#PBS -l walltime=2:00:00:00
#PBS -l nodes=1:ppn=1
#PBS -l mem=15gb
#PBS -e phase_ped.err
#PBS -o phase_ped.log
#PBS -M smozaffari@uchicago.edu

export TMPDIR=$WORKDIR
cd $PBS_O_WORKDIR
export TEMP=$WORKDIR

module load plink

#PO data
plink --bfile /group/ober-resources/resources/Hutterites/PRIMAL/imputed-override3/imputed_cgi.po --keep PO_ids --missing --out phasedPO_AD_gexppl --recode 12 --transpose

#regular data
#from qc set

for snp in `seq 1 22` 
do
  awk -v snp=$snp -F" " '$1 == "'"$snp"'" {print}' phasedPO_AD_gexppl.tped | awk '{for(i=2;i<=NF;i=i+2){printf "%s ", $i}{printf "%s", RS}}' > 'chr'$snp'_phased'
done
