#!/bin/bash 

scriptName=$(basename ${0})
scriptName=${scriptName%\.sh}
scriptDir=$(readlink -f "$(dirname "$0")")
echo $scriptDir


while read LINE; do
    echo "$LINE"
    mkdir $LINE
    echo $LINE
    echo "HUTTERITES ${LINE}2" > $LINE/${LINE}2.txt
    echo "HUTTERITES ${LINE}1" > $LINE/${LINE}1.txt
    echo "qsub -v FINDIV=$LINE $scriptDir/geno.pbs"
    qsub -v FINDIV=$LINE $scriptDir/geno.pbs
    sleep 3
done < /group/ober-resources/users/smozaffari/ASE/data/findiv100092