#!/bin/bash 

scriptName=$(basename ${0})
scriptName=${scriptName%\.sh}
scriptDir=$(readlink -f "$(dirname "$0")")
echo $scriptDir


while read LINE; do
    echo "$LINE"
    mkdir $LINE
    echo $LINE
    echo "HUTTERITES ${LINE}" > $LINE/${LINE}.txt
    echo "qsub -v FINDIV=$LINE $scriptDir/geno_reg.pbs"
#    qsub -v FINDIV=$LINE $scriptDir/geno_reg.pbs
    qsub -v FINDIV=$LINE /group/ober-resources/users/smozaffari/ASE/bin/tarbellscripts/geno.pbs
    sleep 3
done < /group/ober-resources/users/smozaffari/ASE/data/newfull_findivlist