#!/bin/bash
# Script that will be executed on the compute nodes

. /opt/modules/default/init/bash
if [ ! $(module list -t 2>&1 | grep PrgEnv-gnu) ]; then
 module swap PrgEnv-cray PrgEnv-gnu
fi

export PATH="/lustre/beagle2/ober/users/smozaffari/miniconda2/bin:$PATH"

module load bowtie2

module load bcftools

module load samtools/1.2

SCRIPTDIR=$1
FLOWCELLFINDIV=$2
export INPUTDIR=$3
export SNP_DIR=$4
export WASP=$SCRIPTDIR/WASP
export lane=$5
export file=$6
echo $file 

scriptName=$(basename ${0})
echo $scriptName
scriptName=${scriptName%\.sh}
echo $scriptName

#timeTag=$(date "+%y_%m_%d_%H_%M_%S")
ID=$(echo "$FLOWCELLFINDIV" | sed 's/\//./g')
FINDIV=$(echo "$FLOWCELLFINDIV" | awk -F'/' '{print $2}')
echo $ID
echo $FINDIV

plog=$PWD/PO_${LOGNAME}_${FINDIV}.log
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
    lane=$5
    echo "$fastq"
    IFS=','
    fastqs=( $fastq)
    for i in "${fastqs[@]}"; do
	ADAPTOR_SEQ="GATCGGAAGAGCACACGTCTGAACTCCAGTCAC${index}ATCTCGTATGCCGTCTTCTGCTTG"
	echo "$ADAPTOR_SEQ"
	output=$(echo "$i" | sed 's/txt.gz/trim.txt/g')
	echo "$output"
	echo "$index"
	echo "cutadapt -b $ADAPTOR_SEQ --format FASTQ -o $output $i"
	cutadapt -b $ADAPTOR_SEQ --format FASTQ -o $output $i
    done
    IFS=''
}


MAP_AND_SAM() {   # map files using bowtie
    read=$1
    findiv=$2
    IFS=''
    input=$3
    lane=$4
    echo "$input"

    echo "bowtie2 -p 4 --very-fast --phred33 -x /lustre/beagle2/ober/users/smozaffari/ASE/bin/ref/hg19/bowtie2Index/genome -U $input -S $read/${findiv}_${lane}.sam"
    bowtie2-align -p 4 --very-fast --phred33 -x /lustre/beagle2/ober/users/smozaffari/ASE/bin/ref/hg19/bowtie2Index/genome -U $input -S $read/${findiv}_${lane}.sam
    echo "samtools view -S -h -q 10 -b $read/${findiv}_${lane}.sam > $read/${findiv}_${lane}.bam"
    samtools view -S -h -q 10 -b $read/${findiv}_${lane}.sam > $read/${findiv}_${lane}.bam
    echo "samtools sort $read/${findiv}_${lane}.bam $read/${findiv}_${lane}.sorted"
    samtools sort $read/${findiv}_${lane}.bam $read/${findiv}_${lane}.sorted
    echo "samtools view -c $read/${findiv}_${lane}.sorted.bam > $read/${findiv}_${lane}.sorted.txt"
    samtools view -c $read/${findiv}_${lane}.sorted.bam > $read/${findiv}_${lane}.sorted.txt
    echo "samtools index $read/${findiv}_${lane}.sorted.bam"
    samtools index $read/${findiv}_${lane}.sorted.bam 

}

WASP() { # use WASP to remove mapping bias
    read=$1
    findiv=$2
    snp_dir=$3

    #first part of WASP:
    python $WASP/mapping/find_intersecting_snps.py $read/${findiv}.sorted.bam  $snp_dir
    echo "python $WASP/mapping/find_intersecting_snps.py $read/${findiv}_${lane}.sorted.bam  $snp_dir"

    #remap files:
    echo "bowtie2 -p 4 --very-fast --phred33 -x /lustre/beagle2/ober/users/smozaffari/ASE/bin/ref/hg19/bowtie2Index/genome -U $read/${findiv}_${lane}.sorted.remap.fq.gz -S $read/${findiv}_${lane}.sorted.map2.sam"
    bowtie2 -p 4 --very-fast --phred33 -x /lustre/beagle2/ober/users/smozaffari/ASE/bin/ref/hg19/bowtie2Index/genome -U $read/${findiv}_${lane}.sorted.remap.fq.gz -S $read/${findiv}_${lane}.sorted.map2.sam
    wait
    samtools view -S -b -h -q 10 $read/${findiv}_${lane}.sorted.map2.sam >  $read/${findiv}_${lane}.sorted.remap.bam
    echo "samtools view -S -b -h -q 10 $read/${findiv}_${lane}.sorted.map2.sam >  $read/${findiv}_${lane}.sorted.remap.bam"

    #WASP:
    python $WASP/mapping/filter_remapped_reads.py $read/${findiv}.sorted.to.remap.bam $read/${findiv}.sorted.remap.bam $read/${findiv}.sorted.remap.keep.bam $read/${findiv}.sorted.to.remap.num.gz
    echo "python $WASP/mapping/filter_remapped_reads.py $read/${findiv}.sorted.to.remap.bam $read/${findiv}.sorted.remap.bam $read/${findiv}.sorted.remap.keep.bam $read/${findiv}.sorted.to.remap.num.gz"
    wait

    #merged bamfile:
    samtools merge $read/${findiv}.keep.merged.bam $read/${findiv}.sorted.keep.bam $read/${findiv}.sorted.remap.keep.bam
    echo "samtools merge $read/${findiv}.keep.merged.bam $read/${findiv}.sorted.keep.bam $read/${findiv}.sorted.remap.keep.bam"
    samtools sort $read/${findiv}.keep.merged.bam $read/${findiv}.keep.merged.sorted
    echo "samtools sort $read/${findiv}.keep.merged.bam $read/${findiv}.keep.merged.sorted"
    samtools index $read/${findiv}.keep.merged.sorted.bam
    echo "samtools index $read/${findiv}.keep.merged.sorted.bam"

    samtools index $read/${findiv}.sorted.sort.bam
    echo "samtools index $read/${findiv}.sorted.sort.bam"
    samtools view $read/${findiv}.sorted.sort.bam chrX -b > $read/${findiv}.chrX.bam
    echo "samtools view $read/${findiv}.sorted.sort.bam chrX -b > $read/${findiv}.chrX.bam"

    samtools view $read/${findiv}.sorted.sort.bam chrY -b > $read/${findiv}.chrY.bam
    echo "samtools view $read/${findiv}.sorted.sort.bam chrY -b > $read/${findiv}.chrY.bam"

    samtools view $read/${findiv}.sorted.sort.bam chrM -b > $read/${findiv}.chrM.bam
    echo "samtools view $read/${findiv}.sorted.sort.bam chrM -b > $read/${findiv}.chrM.bam"


#    samtools merge $read/${findiv}.withX.bam $read/${findiv}.keep.merged.bam $read/${findiv}.chrX.bam $read/${findiv}.chrY.bam $read/${findiv}.chrM.bam
#    echo "samtools merge $read/${findiv}.withX.bam $read/${findiv}.keep.merged.bam $read/${findiv}.chrX.bam $read/${findiv}.chrY.bam $read/${findiv}.chrM.bam"
#    samtools sort $read/${findiv}.withX.bam $read/${findiv}.sort.withX
#    echo "samtools sort $read/${findiv}.withX.bam $read/${findiv}.sort.withX"
#    samtools index $read/${findiv}.sort.withX.bam
#    echo "samtools index $read/${findiv}.sort.withX.bam"

}



ASE() {
    read=$1
    findiv=$2
    scriptdir=$3
#    python $scriptdir/findsnps.py $read/${findiv}.keep.merged.sorted.bam /group/ober-resources/users/smozaffari/ASE/data/genotypes/$findiv > $read/${findiv}_reads_with_indels
    python $scriptdir/findsnps.py $read/${findiv}.keep.merged.sorted.bam /lustre/beagle2/ober/users/smozaffari/ASE/data/genotypes/$findiv > $read/${findiv}_ASE_info
}

GENECOUNT() {
    read=$1
    findiv=$2
    scriptdir=$3
#    samtools view  $read/${findiv}.keep.merged.sorted.bam |  htseq-count -s no -m intersection-nonempty -a 30 - /lustre/beagle2/ober/users/smozaffari/ASE/bin/ref/hg19/Annotation/genes.gtf > $read/${findiv}_genes
    samtools view $read/${findiv}.sort.withX.bam |  htseq-count -s no -m intersection-nonempty -a 30 - /lustre/beagle2/ober/users/smozaffari/ASE/bin/ref/hg19/Annotation/genes.gtf > $read/${findiv}_genes_withsex
    samtools view  $read/${findiv}.keep.merged.sorted.maternal.bam |  htseq-count -s no -m intersection-nonempty -a 30 - /lustre/beagle2/ober/users/smozaffari/ASE/bin/ref/hg19/Annotation/genes.gtf > $read/${findiv}_genes_maternal
    samtools view  $read/${findiv}.keep.merged.sorted.paternal.bam |  htseq-count -s no -m intersection-nonempty -a 30 - /lustre/beagle2/ober/users/smozaffari/ASE/bin/ref/hg19/Annotation/genes.gtf > $read/${findiv}_genes_paternal
    samtools view $read/${findiv}.keep.merged.sorted.keep.bam | htseq-count -s no -m intersection-nonempty -a 30 - /lustre/beagle2/ober/users/smozaffari/ASE/bin/ref/hg19/Annotation/genes.gtf > $read/${findiv}_genes_hom

}

SEXGENES() {
    read=$1
    findiv=$2
    samtools index $read/${findiv}.sorted.sort.bam
    echo "samtools index $read/${findiv}.sorted.sort.bam"
    samtools view $read/${findiv}.sorted.sort.bam chrX -b > $read/${findiv}.chrX.bam
    echo "samtools view $read/${findiv}.sorted.sort.bam chrX -b > $read/${findiv}.chrX.bam"

    samtools view $read/${findiv}.sorted.sort.bam chrY -b > $read/${findiv}.chrY.bam
    echo "samtools view $read/${findiv}.sorted.sort.bam chrY -b > $read/${findiv}.chrY.bam"

    samtools view $read/${findiv}.sorted.sort.bam chrM -b > $read/${findiv}.chrM.bam
    echo "samtools view $read/${findiv}.sorted.sort.bam chrM -b > $read/${findiv}.chrM.bam"


    samtools merge $read/${findiv}.withX.bam $read/${findiv}.keep.merged.bam $read/${findiv}.chrX.bam $read/${findiv}.chrY.bam $read/${findiv}.chrM.bam
    echo "samtools merge $read/${findiv}.withX.bam $read/${findiv}.keep.merged.bam $read/${findiv}.chrX.bam $read/${findiv}.chrY.bam $read/${findiv}.chrM.bam"
    samtools sort $read/${findiv}.withX.bam $read/${findiv}.sort.withX
    echo "samtools sort $read/${findiv}.withX.bam $read/${findiv}.sort.withX"
    samtools index $read/${findiv}.sort.withX.bam
    echo "samtools index $read/${findiv}.sort.withX.bam"

    samtools view $read/${findiv}.sort.withX.bam |  htseq-count -s no -m intersection-nonempty -a 30 - /lustre/beagle2/ober/users/smozaffari/ASE/bin/ref/hg19/Annotation/genes.gtf > $read/${findiv}_genes_withsex
}

COUNTREADS() {
    read=$1
    findiv=$2

    samtools view -c $read/${findiv}.sorted.bam > $read/${findiv}.sorted.txt
    echo "samtools view -c $read/${findiv}.sorted.bam > $read/${findiv}.sorted.txt"
    samtools view -c $read/${findiv}.sort.withX.bam >>$read/${findiv}.sorted.txt
    echo "samtools view -c $read/${findiv}.sort.withX.bam >>$read/${findiv}.sorted.txt"

    samtools view -c $read/${findiv}.keep.merged.sorted.bam >>$read/${findiv}.sorted.txt
    echo "samtools view -c $read/${findiv}.keep.merged.sorted.bam >>$read/${findiv}.sorted.txt"
    samtools view -c $read/${findiv}.keep.merged.sorted.keep.bam >>$read/${findiv}.sorted.txt
    echo "samtools view -c $read/${findiv}.keep.merged.sorted.keep.bam >>$read/${findiv}.sorted.txt"
    samtools view -c $read/${findiv}.keep.merged.sorted.paternal.bam >>$read/${findiv}.sorted.txt
    echo "samtools view -c $read/${findiv}.keep.merged.sorted.paternal.bam >>$read/${findiv}.sorted.txt"
    samtools view -c $read/${findiv}.keep.merged.sorted.maternal.bam >>$read/${findiv}.sorted.txt
    echo "samtools view -c $read/${findiv}.keep.merged.sorted.maternal.bam >>$read/${findiv}.sorted.txt"
}

export -f TRIM_READ
export -f MAP_AND_SAM
export -f WASP
export -f ASE
export -f GENECOUNT

#echo $fastqList
echo $FILE
echo $SNP_DIR 
echo $SCRIPTDIR

TRIM_READ $READ $FINDIV $FILE $adaptor $lane >>$plog 2>&1 
echo "TRIM_READ $READ $FINDIV $FILE $adaptor $lane  >>$plog 2>&1"

input=$(echo "$FILE" | sed 's/txt.gz/trim.txt/g')
echo "$input"
MAP_AND_SAM $READ $FINDIV $input $lane >>$plog 2>&1                                                       
echo "MAP_AND_SAM $READ $FINDIV $input  >>$plog 2>&1"

#WASP $READ $FINDIV $SNP_DIR >>$plog 2>&1
echo "WASP $READ $FINDIV $SNP_DIR >>$plog 2>&1"

#ASE $READ $FINDIV $SCRIPTDIR >>$plog 2>&1
echo "ASE $READ $FINDIV $SCRIPTDIR >>$plog 2>&1"

#GENECOUNT $READ $FINDIV $SCRIPTDIR >>$plog 2>&1
echo "GENECOUNT $READ $FINDIV $SCRIPTDIR >>$plog 2>&1"

#SEXGENES $READ $FINDIV >>$plog 2>&1
echo "SEXGENES $READ $FINDIV >>$plog 2>&1"

#COUNTREADS $READ $FINDIV >>$plog 2>&1
echo "COUNTREADS $READ $FINDIV >>$plog 2>&1"