#!/bin/bash
#PBS -N plot
#PBS -l walltime=00:30:00
#PBS -l nodes=1:ppn=1
#PBS -l mem=8gb
#PBS -M smozaffari@uchicago.edu



cd $PBS_O_WORKDIR
echo $PBS_O_WORKDIR
module load R
module load plink


echo "Rscript /group/ober-resources/users/smozaffari/ASE/bin/plotscripts/plot_allele.R $GENE $CHR $SNP"
Rscript /group/ober-resources/users/smozaffari/ASE/bin/plotscripts/plot_allele.R $GENE $CHR $SNP

wait