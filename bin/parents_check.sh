#!/bin/bash    
echo "gene good uniquedads uniquemoms totaldads totalmoms bad uniquedads2 uniquemoms2 totaldads2 totalmoms2"


top10genes=("ERAP2" "FAM50B" "KCNQ1" "L3MBTL1" "LPAR6" "PEG10" "PWAR6" "SNHG14" "ZDBF2" "ZNF331")

DIR="/scratch/smozaffari/"

for gene in "${top10genes[@]}"
do
awk 'NR==FNR{a[$1]=$0;next} ($2) in a{print $2, $3, $4}' $DIR/good_${gene} /group/ober-resources/resources/Hutterites/PRIMAL/data-sets/qc__2017-05-05/imputed-override.fam > $DIR/good_${gene}_parents
good=$(cat  $DIR/good_${gene} | wc -l)
awk 'NR==FNR{a[$2]=$1;next} ($2) in a{print $2}' $DIR/good_${gene}_parents /group/ober-resources/resources/Hutterites/PRIMAL/data-sets/qc__2017-05-05/imputed-override.fam > $DIR/1_${gene}
awk 'NR==FNR{a[$3]=$1;next} ($2) in a{print $2}' $DIR/good_${gene}_parents /group/ober-resources/resources/Hutterites/PRIMAL/data-sets/qc__2017-05-05/imputed-override.fam > $DIR/2_${gene}



udads=$(cut -f2 -d" "  $DIR/good_${gene}_parents | sort | uniq -c | wc -l)
umoms=$(cut -f3 -d" "  $DIR/good_${gene}_parents | sort | uniq -c | wc -l)
tdads=$(grep -wf $DIR/1_${gene} $DIR/good_${gene}_parents | wc -l)
tmoms=$(grep -wf $DIR/2_${gene} $DIR/good_${gene}_parents | wc -l)



awk 'NR==FNR{a[$1]=$0;next} ($2) in a{print $2, $3, $4}' $DIR/bad_${gene} /group/ober-resources/resources/Hutterites/PRIMAL/data-sets/qc__2017-05-05/imputed-override.fam > $DIR/bad_${gene}_parents
bad=$(cat $DIR/bad_${gene} | wc -l)
awk 'NR==FNR{a[$2]=$1;next} ($2) in a{print $2}' $DIR/bad_${gene}_parents /group/ober-resources/resources/Hutterites/PRIMAL/data-sets/qc__2017-05-05/imputed-override.fam > $DIR/bad1_${gene}
awk 'NR==FNR{a[$3]=$1;next} ($2) in a{print $2}' $DIR/bad_${gene}_parents /group/ober-resources/resources/Hutterites/PRIMAL/data-sets/qc__2017-05-05/imputed-override.fam > $DIR/bad2_${gene}



udads2=$(cut -f2 -d" "  $DIR/bad_${gene}_parents | sort | uniq -c | wc -l)
umoms2=$(cut -f3 -d" "  $DIR/bad_${gene}_parents | sort | uniq -c | wc -l)
tdads2=$(grep -wf $DIR/bad1_${gene} $DIR/bad_${gene}_parents | wc -l)
tmoms2=$(grep -wf $DIR/bad2_${gene} $DIR/bad_${gene}_parents | wc -l)


echo "$gene $good $udads $umoms $tdads $tmoms $bad $udads2 $umoms2 $tdads2 $tmoms2"

done