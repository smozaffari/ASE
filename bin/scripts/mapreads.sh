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

export PATH="/lustre/beagle2/ober/users/smozaffari/anaconda/bin:$PATH"

python /lustre/beagle2/ober/users/smozaffari/ASE/bin/scripts/WASP/WASP-master/mapping/find_intersecting_snps.py /lustre/beagle2/ober/users/smozaffari/ASE/data/bamfiles/lane*.bam /lustre/beagle2/ober/users/smozaffari/ASE/data/SNP_files