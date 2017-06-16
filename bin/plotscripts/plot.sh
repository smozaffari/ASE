#!/bin/bash

inputFile=$(readlink -f $1)
echo $inputFile

while read -r line; do
    echo $line
    Gene=$(echo $line | cut -f1 -d" ")
    Chr=$(echo $line | cut -f2 -d" ")
    Snp=$(echo $line | cut -f3 -d" ")
    echo "qsub -v GENE=\"$Gene\",CHR=\"$Chr\",SNP=\"$Snp\" -N ${Gene}_${Snp} /group/ober-resources/users/smozaffari/ASE/bin/plotscripts/plot_qsub.sh"
    qsub -v GENE=$Gene,CHR=$Chr,SNP=$Snp -N ${Gene}_${Snp} /group/ober-resources/users/smozaffari/ASE/bin/plotscripts/plot_qsub.sh

done < $inputFile