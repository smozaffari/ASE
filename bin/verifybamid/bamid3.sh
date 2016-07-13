#!/bin/bash
# verify bam id on everyone
# this runs one person, one flowcell/lane at a time ?
# change first four lines
# load plink
# load verifyBamID / to download latest version: from John:
### Clone from GitHub using SSH (can alternatively use HTTPS)
### git clone git@github.com:statgen/verifyBamID.git
### cd verifyBamID
### make cloneLib
### make
### The executable binary is in the subdirectory bin/.


#these four lines are for beagle
. /opt/modules/default/init/bash
if [ ! $(module list -t 2>&1 | grep PrgEnv-gnu) ]; then
 module swap PrgEnv-cray PrgEnv-gnu
fi

module load python/2.7.6-vanilla
#loaded to run plink-1.99

scriptName=$(basename ${0})
echo $scriptName
scriptName=${scriptName%\.sh}
echo $scriptName
scriptDir=$(readlink -f "$(dirname "$0")")
echo $scriptDir

timeTag=$(date "+%y_%m_%d_%H_%M_%S")

plog=$PWD/verifybamid_${LOGNAME}_${timeTag}.log
echo $plog


GENOTYPES() {
    FINDIV=$1

    echo "HUTTERITES "$FINDIV | tee $plog
    echo "HUTTERITES "$FINDIV > $FINDIV.txt

#copied plink files from tarbell to Beagle - give location of these files
    echo "plink-1.9 --bfile /lustre/beagle2/ober/users/smozaffari/Hutterites/PRIMAL/data-sets/qc/qc --keep-allele-order --keep $FINDIV.txt --recode vcf --out $FINDIV" | tee $plog
#    plink-1.9 --bfile /lustre/beagle2/ober/users/smozaffari/Hutterites/PRIMAL/data-sets/qc/qc --keep-allele-order --keep ${FINDIV}.txt --recode vcf --out $FINDIV

    FC=$2
    LANE=$3

#path to verifyBamID
    echo "/lustre/beagle2/ober/users/smozaffari/verifyBamID/verifyBamID/bin/verifyBamID --vcf ${FINDIV}.vcf  --bam /lustre/beagle2/ober/users/smozaffari/ASE/results/star/$FC/$FINDIV/${FINDIV}_${LANE}.sorted.bam  --ignoreRG --smID HUTTERITES_${FINDIV} --self --verbose --out ${FINDIV}_self" | tee $plog
    /lustre/beagle2/ober/users/smozaffari/verifyBamID/verifyBamID/bin/verifyBamID --vcf ${FINDIV}.vcf  --bam /lustre/beagle2/ober/users/smozaffari/ASE/results/star/$FC/$FINDIV/${FINDIV}_${LANE}.sorted.bam  --ignoreRG --smID HUTTERITES_${FINDIV} --self --verbose --out ${FINDIV}_self

}


export -f GENOTYPES

#GENOTYPES $1 $2 $3 >>$plog 2>&1
#echo "GENOTYPES $1 $2 $3 >>$plog 2>&1"

echo "parallel --xapply -d \":\" -j $4 GENOTYPES ::: $1 ::: $2 ::: $3 2>&1"
parallel --xapply -d : -j $4 GENOTYPES  ::: $1 ::: $2 ::: $3 2>&1