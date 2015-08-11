####PRIMAL to IMPUTE2 files:


    plink --bfile /group/ober-resources/resources/Hutterites/PRIMAL/imputed-override3/imputed_cgi.po --geno 0.15 --out phasedPO_g0.15 --recode 12 --transpose

do for each chromosome:

    awk -F" " '$1 == "20" {print}' phasedPO_g0.15.tped | awk '{for(i=2;i<=NF;i=i+2){printf "%s ", $i}{printf "%s", RS}}' > chr20_phased

