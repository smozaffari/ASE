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

plink --bfile /group/ober-resources/resources/Hutterites/PRIMAL/imputed-override3/imputed_cgi.po --recodeA --recode-allele recode.txt --geno 0.15
