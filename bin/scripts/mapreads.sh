 #!/bin/bash
#PBS -N ase_map
#PBS -l walltime=2:00:00:00
#PBS -l nodes=1:ppn=1
#PBS -l mem=15gb
#PBS -e ase_map.err
#PBS -o ase_map.log
#PBS -M smozaffari@uchicago.edu

export TMPDIR=$WORKDIR
cd $PBS_O_WORKDIR
export TEMP=$WORKDIR

module load python

python ../../bin/asescripts/WASP-master/mapping/find_intersecting_snps.py input.bam SNP_files/
