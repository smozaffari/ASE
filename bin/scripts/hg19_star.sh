#!/bin/bash
# Script that will be executed on the compute nodes

. /opt/modules/default/init/bash
if [ ! $(module list -t 2>&1 | grep PrgEnv-gnu) ]; then
 module swap PrgEnv-cray PrgEnv-gnu
fi

export PATH="/lustre/beagle2/ober/users/smozaffari/miniconda2/bin:$PATH"

module load bcftools
module load samtools/1.3
module load bedtools

SCRIPTDIR=$1
FLOWCELLFINDIV=$2
export INPUTDIR=$3
export SNP_DIR=$4
export WASP=$SCRIPTDIR/WASP
export lane=$5
export file=$6
echo $file 
echo $lane

scriptName=$(basename ${0})
echo $scriptName
scriptName=${scriptName%\.sh}
echo $scriptName

#timeTag=$(date "+%y_%m_%d_%H_%M_%S")
ID=$(echo "$FLOWCELLFINDIV" | sed 's/\//./g')
FINDIV=$(echo "$FLOWCELLFINDIV" | awk -F'/' '{print $2}')
echo $ID
echo $FINDIV

plog=$PWD/PO_${LOGNAME}_${FINDIV}_${lane}_star.log
echo $plog
maplog=$PWD/mapping.log
echo $maplog

echo "RUNNING $scriptName as " $(readlink -f $0 ) " on " `date`  | tee  $plog

#timeTag=$(date "+%y_%m_%d_%H_%M_%S")

echo "RUNNING $scriptName as " $(readlink -f $0 ) " on " `date`  | tee  $plog
#plog=$inputDir/python_WASP_$num

echo "SCRIPTDIR:" $SCRIPTDIR
declare -A adaptor_index
adaptor_index=( [1]="ATCACG" [2]="CGATGT" [3]="TTAGGC" [4]="TGACCA" [5]="ACAGTG" [6]="GCCAAT" [7]="CAGATC" [8]="ACTTGA" [9]="GATCAG" [10]="TAGCTT" [11]="GGCTAC" [12]="CTTGTA" [13]="AGTCAA" [14]="AGTTCC" [15]="ATGTCA" [16]="CCGTCC" [18]="GTCCGC" [19]="GTGAAA" [20]="GTGGCC" [21]="GTTTCG" [22]="CGTACG" [23]="GAGTGG" [25]="ACTGAT" [27]="ATTCCT")

echo ${adaptor_index[1]}

READ=$INPUTDIR/$FLOWCELLFINDIV
echo "$READ"
FILE=$READ/$file

IFS='.'
array=( $file )
indexnum=${array[1]}
IFS='_'
array2=( $indexnum )
index=${array2[1]}
echo "$FINDIV $index"
IFS=''

adaptor=$(echo ${adaptor_index[$index]} )
echo $adaptor

TRIM_READ() { # trim adaptors
    read=$1
    findiv=$2
    fastq=$3
    index=$4
#    sample=$5
    echo "$fastq"
    IFS=','
    fastqs=( $fastq)
    for i in "${fastqs[@]}"; do
	ADAPTOR_SEQ="GATCGGAAGAGCACACGTCTGAACTCCAGTCAC${index}ATCTCGTATGCCGTCTTCTGCTTG"
	echo "$ADAPTOR_SEQ"
	output=$(echo "$i" | sed 's/txt.gz/trim.txt/g')
	tooshort=$(echo "$i" | sed 's/txt.gz/tooshort5.txt/g')
	echo "$output"
	echo "$index"
	echo "cutadapt -b $ADAPTOR_SEQ -m 5 --too-short-output $tooshort --format FASTQ -o $output $i"
	cutadapt -b $ADAPTOR_SEQ -m 5 --too-short-output $tooshort --format FASTQ -o $output $i
    done
    IFS=''
}


MAP_AND_SAM() {   # map files using bowtie
    read=$1
    findiv=$2
    IFS=''
    input=$3
    sample=$4
    echo "$input"
    
    echo "/lustre/beagle2/ober/users/smozaffari/STAR//STAR-2.5.2a/bin/Linux_x86_64/STAR --genomeDir /lustre/beagle2/ober/users/smozaffari/ASE/bin/ref/star/overhang_v19_2018/  --readFilesIn $input  --outFileNamePrefix $read/$sample"
    /lustre/beagle2/ober/users/smozaffari/STAR//STAR-2.5.2a/bin/Linux_x86_64/STAR --genomeDir /lustre/beagle2/ober/users/smozaffari/ASE/bin/ref/star/overhang_v19_2018/ --readFilesIn $input --outFileNamePrefix $read/$sample

    echo "samtools view -q 10 -b $read/${sample}Aligned.out.sam > $read/${sample}.bam"
    samtools view -q 10 -b $read/${sample}Aligned.out.sam > $read/${sample}.bam
    
    echo "samtools sort -o  $read/${sample}.sorted.bam $read/${sample}.bam"
    samtools sort -o  $read/${sample}.sorted.bam $read/${sample}.bam
    

 #   echo "samtools view -c -F 255 $read/${sample}.sorted.bam > $read/${sample}.sorted.txt"
 #   samtools view -c -F 255 $read/${sample}.sorted.bam > $read/${sample}.sorted.txt
    echo "samtools index $read/${sample}.sorted.bam"
    samtools index $read/${sample}.sorted.bam 

}

WASP() { # use WASP to remove mapping bias
    read=$1
    findiv=$2
    snp_dir=$3
    sample=$4
    lane=$5
    #first part of WASP:
    python $WASP/mapping/find_intersecting_snps.py  --snp_dir $snp_dir $read/${sample}.sorted.bam
    echo "python $WASP/mapping/find_intersecting_snps.py --snp_dir  $snp_dir $read/${sample}.sorted.bam"

    #remap files:
    echo "/lustre/beagle2/ober/users/smozaffari/STAR//STAR-2.5.2a/bin/Linux_x86_64/STAR --genomeDir /lustre/beagle2/ober/users/smozaffari/ASE/bin/ref/star/overhang_v19_2018/  --readFilesIn $read/${sample}.sorted.remap.fq.gz --readFilesCommand zcat --outFileNamePrefix $read/${sample}.sorted.map2"
    /lustre/beagle2/ober/users/smozaffari/STAR//STAR-2.5.2a/bin/Linux_x86_64/STAR --genomeDir /lustre/beagle2/ober/users/smozaffari/ASE/bin/ref/star/overhang_v19/ --readFilesIn $read/${sample}.sorted.remap.fq.gz --readFilesCommand zcat --outFileNamePrefix $read/${sample}.sorted.map2
   wait
   
#    rm $read/${sample}.sorted.remap.bam

    echo "samtools view -q 10 -b $read/${sample}.sorted.map2Aligned.out.sam > $read/${sample}.sorted.remap.bam"
    samtools view -q 10 -b $read/${sample}.sorted.map2Aligned.out.sam > $read/${sample}.sorted.remap.bam


#    rm $read/${sample}.sorted.remap.sorted.bam
    echo "samtools sort $read/${sample}.sorted.remap.sorted.bam $read/${sample}.sorted.remap.bam"
    samtools sort -o  $read/${sample}.sorted.remap.sorted.bam $read/${sample}.sorted.remap.bam
    
    
    echo "samtools index $read/${sample}.sorted.remap.sorted.bam"
    samtools index $read/${sample}.sorted.remap.sorted.bam



    #WASP:

    python $WASP/mapping/filter_remapped_reads.py $read/${sample}.sorted.to.remap.bam $read/${sample}.sorted.remap.sorted.bam $read/${sample}.sorted.remap.keep.bam #$read/${sample}.sorted.to.remap.num.gz
    echo "python $WASP/mapping/filter_remapped_reads.py $read/${sample}.sorted.to.remap.bam $read/${sample}.sorted.remap.sorted.bam $read/${sample}.sorted.remap.keep.bam #$read/${sample}.sorted.to.remap.num.gz"
    wait
    
 #   rm $read/${sample}.keep.merged.bam

    #merged bamfile:
    samtools merge $read/${sample}.keep.merged.bam $read/${sample}.sorted.keep.bam $read/${sample}.sorted.remap.keep.bam
    echo "samtools merge $read/${sample}.keep.merged.bam $read/${sample}.sorted.keep.bam $read/${sample}.sorted.remap.keep.bam"


 #   rm $read/${sample}.keep.merged.sorted.bam
    samtools sort -o $read/${sample}.keep.merged.sorted.bam $read/${sample}.keep.merged.bam
    echo "samtools -o sort $read/${sample}.keep.merged.sorted.bam $read/${sample}.keep.merged.bam"


    samtools index $read/${sample}.keep.merged.sorted.bam
    echo "samtools index $read/${sample}.keep.merged.sorted.bam"

    python $WASP/mapping/rmdup.py $read/${sample}.keep.merged.sorted.bam $read/${sample}.afterWASP.nodup.bam
    echo "remove duplicates: python $WASP/mapping/rmdup.py $read/${sample}.keep.merged.sorted.bam $read/${sample}.afterWASP.nodup.bam"
}



ASE() {
    read=$1
    findiv=$2
    scriptdir=$3
    sample=$4
    echo "python $scriptdir/findsnps_new.py --is_sorted --max_snps 20 --snp_dir /lustre/beagle2/ober/users/smozaffari/po_genotypes/$findiv $read/${sample}.afterWASP.nodup.bam >$read/${sample}_ASE_info.nodup"
    python $scriptdir/findsnps_new.py --is_sorted --max_snps 20 --snp_dir /lustre/beagle2/ober/users/smozaffari/po_genotypes/$findiv $read/${sample}.afterWASP.nodup.bam > $read/${sample}_ASE_info.nodup
#     echo "python $scriptdir/findsnps_new.py  --is_sorted --max_snps 20 --snp_dir  /lustre/beagle2/ober/users/smozaffari/ASE_swappedgenotypes/$findiv $read/${sample}.keep.merged.sorted.bam > $read/${sample}_ASE_info"
#     python $scriptdir/findsnps_new.py  --is_sorted --max_snps 20 --snp_dir  /lustre/beagle2/ober/users/smozaffari/ASE_swappedgenotypes/$findiv $read/${sample}.keep.merged.sorted.bam > $read/${sample}_ASE_info

#ASE_swappedgenotypes
}

SEXGENES() {
    read=$1
    sample=$2
    samtools index $read/${sample}.afterWASP.nodup.bam
    echo "samtools index $read/${sample}.afterWASP.nodup.bam"
    samtools view $read/${sample}.afterWASP.nodup.bam chrX -b > $read/${sample}.chrX.nodup.bam
    echo "samtools view $read/${sample}afterWASP.nodup.bam chrX -b > $read/${sample}.chrX.nodup.bam"

    samtools view $read/${sample}.afterWASP.nodup.bam chrY -b > $read/${sample}.chrY.nodup.bam
    echo "samtools view $read/${sample}.afterWASP.nodup.bam chrY -b > $read/${sample}.chrY.nodup.bam"

    samtools view $read/${sample}.afterWASP.nodup.bam chrM -b > $read/${sample}.chrM.nodup.bam
    echo "samtools view $read/${sample}.afterWASP.nodup.bam chrM -b > $read/${sample}.chrM.nodup.bam"

    rm $read/${sample}.withX.nodup.bam 

    samtools merge $read/${sample}.withX.nodup.bam $read/${sample}.afterWASP.nodup.bam $read/${sample}.chrX.nodup.bam $read/${sample}.chrY.nodup.bam $read/${sample}.chrM.nodup.bam
    echo "samtools merge $read/${sample}.withX.nodup.bam $read/${sample}.afterWASP.nodup.bam $read/${sample}.chrX.nodup.bam $read/${sample}.chrY.nodup.bam $read/${sample}.chrM.nodup.bam"
#    samtools sort $read/${sample}.withX.bam $read/${sample}.sort.withX
#    echo "samtools sort $read/${sample}.withX.bam $read/${sample}.sort.withX"

    rm $read/${sample}.sort.withX.nodup.bam
    samtools sort -o $read/${sample}.sort.withX.nodup.bam $read/${sample}.withX.nodup.bam
    echo "samtools sort -o $read/${sample}.sort.withX.nodup.bam $read/${sample}.withX.nodup.bam"

    samtools index $read/${sample}.sort.withX.nodup.bam
    echo "samtools index $read/${sample}.sort.withX.nodup.bam"

    echo "samtools view $read/${sample}.sort.withX.nodup.bam |  htseq-count -s no -m intersection-nonempty -a 30 - /lustre/beagle2/ober/users/smozaffari/ASE/bin/ref/hg19/Annotation/genes.gtf > $read/${sample}_genes_withsex_nodup"
    samtools view $read/${sample}.sort.withX.nodup.bam |  htseq-count -s no -m intersection-nonempty -a 30 - /lustre/beagle2/ober/users/smozaffari/ASE/bin/ref/hg19/Annotation/genes.gtf > $read/${sample}_genes_withsex_nodup
}

COUNTREADS() {
    read=$1
    sample=$2

    samtools view -c -F 256 $read/${sample}.sorted.bam > $read/${sample}.sorted.nodup.txt
    echo "samtools view -c -F 256 $read/${sample}.sorted.bam > $read/${sample}.sorted.nodup.txt"
    samtools view -c -F 256 $read/${sample}.sort.withX.nodup.bam >>$read/${sample}.sorted.nodup.txt
    echo "samtools view -c -F 256 $read/${sample}.sort.withX.nodup.bam >>$read/${sample}.sorted.nodup.txt"

    samtools view -c -F 256 $read/${sample}.afterWASP.nodup.bam >>$read/${sample}.sorted.nodup.txt
    echo "samtools view -c -F 256 $read/${sample}.afterWASP.nodup.bam >>$read/${sample}.sorted.nodup.txt"
    samtools view -c -F 256 $read/${sample}.afterWASP.nodup.hom.bam >>$read/${sample}.sorted.nodup.txt
    echo "samtools view -c -F 256 $read/${sample}.afterWASP.nodup.hom.bam >>$read/${sample}.sorted.nodup.txt"
    samtools view -c -F 256 $read/${sample}.afterWASP.nodup.bam >>$read/${sample}.sorted.nodup.txt
    echo "samtools view -c -F 256 $read/${sample}.afterWASP.nodup.paternal.bam >>$read/${sample}.sorted.nodup.txt"
    samtools view -c -F 256 $read/${sample}.afterWASP.nodup.bam >>$read/${sample}.sorted.nodup.txt
    echo "samtools view -c -F 256 $read/${sample}.afterWASP.nodup.maternalbam >>$read/${sample}.sorted.nodup.txt"
}

GENECOUNT() {
    read=$1
    sample=$2

    samtools view  $read/${sample}.afterWASP.nodup.bam |  htseq-count -s no -m intersection-nonempty -a 30 - /lustre/beagle2/ober/users/smozaffari/ASE/bin/ref/hg19/Annotation/genes.gtf > $read/${sample}_genes_nodup
#    samtools view $read/${sample}.sort.withX.bam |  htseq-count -s no -m intersection-nonempty -a 30 - /lustre/beagle2/ober/users/smozaffari/ASE/bin/ref/hg19/Annotation/genes.gtf > $read/${sample}_genes_withsex                                                                                                  
    samtools view  $read/${sample}.afterWASP.nodup.maternal.bam |  htseq-count -s no -m intersection-nonempty -a 30 - /lustre/beagle2/ober/users/smozaffari/ASE/bin/ref/hg19/Annotation/genes.gtf > $read/${sample}_genes_maternal_nodup
    samtools view  $read/${sample}.afterWASP.nodup.paternal.bam |  htseq-count -s no -m intersection-nonempty -a 30 - /lustre/beagle2/ober/users/smozaffari/ASE/bin/ref/hg19/Annotation/genes.gtf > $read/${sample}_genes_paternal_nodup
    samtools view $read/${sample}.afterWASP.nodup.hom.bam | htseq-count -s no -m intersection-nonempty -a 30 - /lustre/beagle2/ober/users/smozaffari/ASE/bin/ref/hg19/Annotation/genes.gtf > $read/${sample}_genes_hom_nodup

}


ALTGENECOUNT() {
    read=$1
    sample=$2

 #   samtools merge $read/${sample}.all.bam $read/${sample}.sort.withX.bam $read/${sample}.keep.merged.sorted.maternal.bam $read/${sample}.keep.merged.sorted.paternal.bam $read/${sample}.keep.merged.sorted.hom.bam


    bedtools bamtofastq -i $read/${sample}.afterWASP.nodup.bam -fq $read/${sample}.afterWASP.nodup.fq
    echo "/lustre/beagle2/ober/users/smozaffari/STAR//STAR-2.5.2a/bin/Linux_x86_64/STAR --genomeDir /lustre/beagle2/ober/users/smozaffari/ASE/bin/ref/star/overhang_v19/  --readFilesIn $read/${sample}.afterWASP.nodup.fq  --outFileNamePrefix $read/${sample}_genesaltcount_nodup  --quantMode GeneCounts"
    /lustre/beagle2/ober/users/smozaffari/STAR//STAR-2.5.2a/bin/Linux_x86_64/STAR --genomeDir /lustre/beagle2/ober/users/smozaffari/ASE/bin/ref/star/overhang_v19/  --readFilesIn $read/${sample}.afterWASP.nodup.fq  --outFileNamePrefix $read/${sample}_genesaltcount_nodup  --quantMode GeneCounts

    bedtools bamtofastq -i $read/${sample}.sort.withX.nodup.bam -fq $read/${sample}.sort.withX.nodup.fq
    echo "/lustre/beagle2/ober/users/smozaffari/STAR//STAR-2.5.2a/bin/Linux_x86_64/STAR --genomeDir /lustre/beagle2/ober/users/smozaffari/ASE/bin/ref/star/overhang_v19/ --readFilesIn $read/${sample}.sort.withX.nodup.fq  --outFileNamePrefix $read/${sample}_genes_withsex_nodup  --quantMode GeneCounts"
   /lustre/beagle2/ober/users/smozaffari/STAR//STAR-2.5.2a/bin/Linux_x86_64/STAR --genomeDir /lustre/beagle2/ober/users/smozaffari/ASE/bin/ref/star/overhang_v19/  --readFilesIn $read/${sample}.sort.withX.nodup.fq  --outFileNamePrefix $read/${sample}_genes_withsex_nodup  --quantMode GeneCounts


    bedtools bamtofastq -i $read/${sample}.afterWASP.nodup.maternal.bam -fq $read/${sample}.afterWASP.nodup.maternal.fq
    echo "/lustre/beagle2/ober/users/smozaffari/STAR//STAR-2.5.2a/bin/Linux_x86_64/STAR --genomeDir /lustre/beagle2/ober/users/smozaffari/ASE/bin/ref/star/overhang_v19/  --readFilesIn $read/${sample}.afterWASP.nodup.maternal.fq  --outFileNamePrefix $read/${sample}_genes_maternalaltcount_nodup  --quantMode GeneCounts "
    /lustre/beagle2/ober/users/smozaffari/STAR//STAR-2.5.2a/bin/Linux_x86_64/STAR --genomeDir /lustre/beagle2/ober/users/smozaffari/ASE/bin/ref/star/overhang_v19/  --readFilesIn $read/${sample}.afterWASP.nodup.maternal.fq  --outFileNamePrefix $read/${sample}_genes_maternalaltcount_nodup  --quantMode GeneCounts

   bedtools bamtofastq -i $read/${sample}.afterWASP.nodup.hom.bam -fq $read/${sample}.afterWASP.nodup.hom.fq
    echo "/lustre/beagle2/ober/users/smozaffari/STAR//STAR-2.5.2a/bin/Linux_x86_64/STAR --genomeDir /lustre/beagle2/ober/users/smozaffari/ASE/bin/ref/star/overhang_v19/  --readFilesIn $read/${sample}.afterWASP.nodup.hom.fq  --outFileNamePrefix $read/${sample}_genes_homaltcount_nodup  --quantMode GeneCounts "
    /lustre/beagle2/ober/users/smozaffari/STAR//STAR-2.5.2a/bin/Linux_x86_64/STAR --genomeDir /lustre/beagle2/ober/users/smozaffari/ASE/bin/ref/star/overhang_v19/  --readFilesIn $read/${sample}.afterWASP.nodup.hom.fq  --outFileNamePrefix $read/${sample}_genes_homaltcount_nodup  --quantMode GeneCounts

   bedtools bamtofastq -i $read/${sample}.afterWASP.nodup.paternal.bam -fq $read/${sample}.afterWASP.nodup.paternal.fq
    echo "/lustre/beagle2/ober/users/smozaffari/STAR//STAR-2.5.2a/bin/Linux_x86_64/STAR --genomeDir /lustre/beagle2/ober/users/smozaffari/ASE/bin/ref/star/overhang_v19/  --readFilesIn $read/${sample}.afterWASP.nodup.paternal.fq  --outFileNamePrefix $read/${sample}_genes_paternalaltcount_nodup  --quantMode GeneCounts "
    /lustre/beagle2/ober/users/smozaffari/STAR//STAR-2.5.2a/bin/Linux_x86_64/STAR --genomeDir /lustre/beagle2/ober/users/smozaffari/ASE/bin/ref/star/overhang_v19/  --readFilesIn $read/${sample}.afterWASP.nodup.paternal.fq  --outFileNamePrefix $read/${sample}_genes_paternalaltcount_nodup  --quantMode GeneCounts


}



export -f TRIM_READ
export -f MAP_AND_SAM
export -f WASP
export -f ASE
export -f GENECOUNT
export -f ALTGENECOUNT

SAMPLE=${FINDIV}_${lane}
LANEWASP=${lane}_WASP
echo $SAMPLE
echo $FILE
echo $SNP_DIR 
echo $SCRIPTDIR
echo $lane
echo $LANEWASP

TRIM_READ $READ $FINDIV $FILE $adaptor $SAMPLE >>$plog 2>&1 
echo "TRIM_READ $READ $FINDIV $FILE $adaptor $SAMPLE  >>$plog 2>&1"

input=$(echo "$FILE" | sed 's/txt.gz/trim.txt/g')
echo "$input"
MAP_AND_SAM $READ $FINDIV $input $SAMPLE >>$plog 2>&1
echo "MAP_AND_SAM $READ $FINDIV $SAMPLE  >>$plog 2>&1"

WASP $READ $FINDIV $SNP_DIR $SAMPLE $LANEWASP>>$plog 2>&1
echo "WASP $READ $FINDIV $SNP_DIR $SAMPLE $LANEWASP>>$plog 2>&1"

ASE $READ $FINDIV $SCRIPTDIR $SAMPLE >>$plog 2>&1
echo "ASE $READ $FINDIV $SCRIPTDIR $SAMPLE >>$plog 2>&1"

SEXGENES $READ  $SAMPLE  >>$plog 2>&1
echo "SEXGENES $READ  $SAMPLE >>$plog 2>&1"

COUNTREADS $READ $SAMPLE >>$plog 2>&1
echo "COUNTREADS $READ $SAMPLE >>$plog 2>&1"

GENECOUNT $READ $SAMPLE >>$plog 2>&1
echo "GENECOUNT $READ $FINDIV $SCRIPTDIR $SAMPLE >>$plog 2>&1"

ALTGENECOUNT $READ $SAMPLE >>$plog 2>&1
echo "GENECOUNT $READ $FINDIV $SCRIPTDIR $SAMPLE >>$plog 2>&1"
 