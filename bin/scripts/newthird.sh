#!/bin/bash
# Script that will be executed on the compute nodes

. /opt/modules/default/init/bash
if [ ! $(module list -t 2>&1 | grep PrgEnv-gnu) ]; then
 module swap PrgEnv-cray PrgEnv-gnu
fi

#export PATH=/lustre/beagle2/lpBuild/python/Python-2.7.10-inst/bin:$PATH                                                           
#export LD_LIBRARY_PATH=/lustre/beagle2/lpBuild/python/Python-2.7.10-inst/lib:$LD_LIBRARY_PATH                                     

export PATH="/lustre/beagle2/ober/users/smozaffari/miniconda2/bin:$PATH"
#export LD_LIBRARY_PATH="/lustre/beagle2/ober/users/smozaffari/miniconda2/lib:$LD_LIBRARY_PATH"
#module load python/2.7.10                                                                                                         
#module load cutadapt                                                                                                              
which python
pip list

env
module list
module load bowtie2/2.2.5
which bowtie2
module load bcftools


module load samtools/1.2
#module load HTSeq             

SCRIPTDIR=$1
FLOWCELLFINDIV=$2
export INPUTDIR=$3
export SNP_DIR=$4
export WASP=$SCRIPTDIR/WASP



scriptName=$(basename ${0})
echo $scriptName
scriptName=${scriptName%\.sh}
echo $scriptName

#timeTag=$(date "+%y_%m_%d_%H_%M_%S")
ID=$(echo "$FLOWCELLFINDIV" | sed 's/\//./g')
FINDIV=$(echo "$FLOWCELLFINDIV" | awk -F'/' '{print $2}')
echo $ID
echo $FINDIV

plog=$PWD/${scriptName}_${LOGNAME}_${FINDIV}.log
echo $plog
maplog=$PWD/mapping.log
echo $maplog

echo "RUNNING $scriptName as " $(readlink -f $0 ) " on " `date`  | tee  $plog

#timeTag=$(date "+%y_%m_%d_%H_%M_%S")

echo "RUNNING $scriptName as " $(readlink -f $0 ) " on " `date`  | tee  $plog
#plog=$inputDir/python_WASP_$num

echo "SCRIPTDIR:" $SCRIPTDIR
declare -A adaptor_index
adaptor_index=( [1]="ATCACG" [2]="CGATGT" [3]="TTAGGC" [4]="TGACCA" [5]="ACAGTG" [6]="GCCAAT" [7]="CAGATC" [8]="ACTTGA" [9]="GATCAG" [10]="TAGCTT" [11]="GGCTAC" [12]="CTTGTA")

echo ${adaptor_index[1]}

READ=$INPUTDIR/$FLOWCELLFINDIV
echo "$READ"

for file in "$READ"/*.sequence.txt.gz; do
#    if [ "$file" /*.sequence.txt.gz ]; then
    echo "$file"
    if [ "$fastqList" ]; then
	fastqList="${fastqList},${file}"
	echo $fastqList
    else
	fastqList=$file
	IFS='.'
	array=( $file )
	indexnum=${array[1]}
	IFS='_'
	array2=( $indexnum )
	index=${array2[1]}
	echo "$FINDIV $index"
	IFS=''
    fi
done
IFS=''
adaptor=$(echo ${adaptor_index[$index]} )
echo $adaptor

TRIM_READ() { # trim adaptors
    read=$1
    findiv=$2
    fastq=$3
    index=$4
    echo "$fastq"
    IFS=','
    fastqs=( $fastq)
    for i in "${fastqs[@]}"; do
	ADAPTOR_SEQ="GATCGGAAGAGCACACGTCTGAACTCCAGTCAC${index}ATCTCGTATGCCGTCTTCTGCTTG"
	echo "$ADAPTOR_SEQ"
	output=$(echo "$i" | sed 's/txt.gz/trim.txt.gz/g')
	echo "$output"
	echo "$index"
	echo "cutadapt -b $ADAPTOR_SEQ --format FASTQ -o $output $i"
	cutadapt -b $ADAPTOR_SEQ --format FASTQ -o $output $i

#	fastqc $output -o $read
#	echo "fastqc $output -o $read"
    done
    IFS=''
}


MAP_AND_SAM() {   # map files using bowtie
    read=$1
    findiv=$2
    IFS=''
    input=$3
    echo "$input"

#/group/referenceFiles/Homo_sapiens/UCSC/hg38/Sequence/IlluminaBowtie2Index/v2.2.5/genome.
    echo "bowtie2 -p 4 --very-fast --phred33 -x /lustre/beagle2/ober/users/smozaffari/ASE/bin/ref/hg38/analysisset/bowtie2Index/genome -U $input -S $read/${findiv}.sam"
    bowtie2 -p 4 --very-fast --phred33 -x /lustre/beagle2/ober/users/smozaffari/ASE/bin/ref/hg38/analysisset/bowtie2Index/genome -U $input -S $read/${findiv}.sam
    echo "samtools view -S -h -q 10 -b $read/${findiv}.sam > $read/${findiv}.bam"
    samtools view -S -h -q 10 -b $read/${findiv}.sam > $read/${findiv}.bam
    echo "samtools sort $read/${findiv}.bam $read/${findiv}.sorted"
    samtools sort $read/${findiv}.bam $read/${findiv}.sorted
    echo "samtools view -c $read/${findiv}.sorted.bam > $read/${findiv}.sorted.txt"
    samtools view -c $read/${findiv}.sorted.bam > $read/${findiv}.sorted.txt
    echo "samtools index $read/${findiv}.sorted.bam"
    samtools index $read/${findiv}.sorted.bam 

#    rm $read/*sequence.trim.txt.gz
#    rm $read/*sequence.txt.gz
}

WASP() { # use WASP to remove mapping bias
    read=$1
    findiv=$2
    snp_dir=$3

    #first part of WASP:
    python $WASP/mapping/find_intersecting_snps.py $read/${findiv}.sorted.bam  $snp_dir
    echo "python $WASP/mapping/find_intersecting_snps.py $read/${findiv}.sorted.bam  $snp_dir"

    #remap files:
    echo "bowtie2 -p 4 --very-fast --phred33 -x /lustre/beagle2/ober/users/smozaffari/ASE/bin/ref/hg38/analysisset/bowtie2Index/genome -U $read/${findiv}.sorted.remap.fq.gz -S $read/${findiv}.sorted.map2.sam"
    bowtie2 -p 4 --very-fast --phred33 -x /lustre/beagle2/ober/users/smozaffari/ASE/bin/ref/hg38/analysisset/bowtie2Index/genome -U $read/${findiv}.sorted.remap.fq.gz -S $read/${findiv}.sorted.map2.sam
    wait
    samtools view -S -b -h -q 10 $read/${findiv}.sorted.map2.sam >  $read/${findiv}.sorted.remap.bam
    echo "samtools view -S -b -h -q 10 $read/${findiv}.sorted.map2.sam >  $read/${findiv}.sorted.remap.bam"

 #   bzip2 $read/${findiv}.sorted.bam

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

    #WASP:
#    python $WASP/mapping/rmdup.py  $read/${findiv}.keep.merged.sorted.bam $read/${findiv}.keep.rmdup.merged.sorted.bam
#    rm $read/*map2.sam
#    rm $read/*remap.bam
#    rm $read/${findiv}.keep.merged.bam
#    rm $read/${findiv}.sorted.remap.keep.bam
#    rm $read/${findiv}.sorted.keep.bam
#    rm $read/${findiv}.sam

}

ASE() {
    read=$1
    findiv=$2
    scriptdir=$3
#    python $scriptdir/findsnps.py $read/${findiv}.keep.merged.sorted.bam /group/ober-resources/users/smozaffari/ASE/data/genotypes/$findiv > $read/${findiv}_reads_with_indels
    python $scriptdir/findsnps.py $read/${findiv}.keep.merged.sorted.bam /group/ober-resources/users/smozaffari/ASE/data/genotypes/$findiv > $read/${findiv}_ASE_info
}

GENECOUNT() {
    read=$1
    findiv=$2
    scriptdir=$3
    samtools view  $read/${findiv}.keep.merged.sorted.bam |  htseq-count -s no -m intersection-nonempty -a 30 - /group/referenceFiles/Homo_sapiens/UCSC/hg19/Annotation/Genes/genes.gtf > $read/${findiv}_genes
    samtools view  $read/${findiv}.keep.merged.sorted.maternal.bam |  htseq-count -s no -m intersection-nonempty -a 30 - /group/referenceFiles/Homo_sapiens/UCSC/hg19/Annotation/Genes/genes.gtf > $read/${findiv}_genes_maternal
    samtools view  $read/${findiv}.keep.merged.sorted.paternal.bam |  htseq-count -s no -m intersection-nonempty -a 30 - /group/referenceFiles/Homo_sapiens/UCSC/hg19/Annotation/Genes/genes.gtf > $read/${findiv}_genes_paternal
    samtools view $read/${findiv}.keep.merged.sorted.keep.bam | htseq-count -s no -m intersection-nonempty -a 30 - /group/referenceFiles/Homo_sapiens/UCSC/hg19/Annotation/Genes/genes.gtf > $read/${findiv}_hom_genes

}
export -f TRIM_READ
export -f MAP_AND_SAM
export -f WASP
export -f ASE
export -f GENECOUNT

echo $fastqList
echo $SNP_DIR 
echo $SCRIPTDIR

TRIM_READ $READ $FINDIV $fastqList $adaptor >>$plog 2>&1 
echo "TRIM_READ $READ $FINDIV $fastqList $adaptor >>$plog 2>&1"

input=$(echo "$fastqList" | sed 's/txt.gz/trim.txt.gz/g')
echo "$input"
MAP_AND_SAM $READ $FINDIV $input >>$plog 2>&1                                                       
echo "MAP_AND_SAM $READ $FINDIV $input  >>$plog 2>&1"


WASP $READ $FINDIV $SNP_DIR >>$plog 2>&1
echo "WASP $READ $FINDIV $SNP_DIR >>$plog 2>&1"

ASE $READ $FINDIV $SCRIPTDIR >>$plog 2>&1
echo "ASE $READ $FINDIV $SCRIPTDIR >>$plog 2>&1"

#GENECOUNT $READ $FINDIV $SCRIPTDIR >>$plog 2>&1
echo "GENECOUNT $READ $FINDIV $SCRIPTDIR >>$plog 2>&1"