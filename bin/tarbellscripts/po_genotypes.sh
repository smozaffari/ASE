#!/bin/bash 

# to submit this, enter './adaptor_list_through.sh' 
# the read command is going to look at whatever file you pipe into the script with the < operator
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
done < /group/ober-resources/users/smozaffari/ASE/data/taillist
