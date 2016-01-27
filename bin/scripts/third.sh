#!/bin/bash
# Script that will be executed on the compute nodes
bamFiles=$1
jobsPerNode=$2
scriptDir=$3
export SNP_DIR=$4
export inputDir=$5
num=$6
export WASP=$scriptDir/WASP

scriptName=$(basename ${0})
echo $scriptName
scriptName=${scriptName%\.sh}
echo $scriptName

#timeTag=$(date "+%y_%m_%d_%H_%M_%S")

plog=$PWD/${scriptName}_${LOGNAME}_${num}.log
echo $plog
maplog=$PWD/mapping.log
echo $maplog

echo "RUNNING $scriptName as " $(readlink -f $0 ) " on " `date`  | tee  $plog
#plog=$inputDir/python_WASP_$num

echo scriptDir $scriptDir
bamFiles=$(echo $bamFiles | sed 's/::/\ /g')

# functions to be used in the call to parallels
FIND_SNPS() {
    #first part of WASP:
    python $WASP/mapping/find_intersecting_snps.py $inputDir/$1 $SNP_DIR
    
    #remap files:
    toRemapfqFiles=$( echo "$1" | sed 's/bam/remap.fq.gz/g' )
    echo $toRemapfqFiles
    saiFile=$(echo "$1" | sed 's/bam/sai/g')
    echo $saiFile
    samFile=$(echo "$1" | sed 's/bam/sam/g')
    echo $samFile
    remappedBamFile=$(echo "$1" | sed 's/bam/remap\.bam/g')
    echo $remappedBamFile
    bwa aln -n 2 -N /lustre/beagle2/ReferenceSequences/Homo_sapiens/UCSC/hg19/Sequence/BWAIndex/genome.fa $inputDir/$toRemapfqFiles > $inputDir/$saiFile
    bwa samse -n 1 /lustre/beagle2/ReferenceSequences/Homo_sapiens/UCSC/hg19/Sequence/BWAIndex/genome.fa $inputDir/$saiFile $inputDir/$toRemapfqFiles > $inputDir/$samFile
    samtools view -S -b -q 10 $inputDir/$samFile >  $inputDir/$remappedBamFile
    echo "bwa aln -n 2 -N /lustre/beagle2/ReferenceSequences/Homo_sapiens/UCSC/hg19/Sequence/BWAIndex/genome.fa $inputDir/$toRemapFiles > $inputDir/$saiFile"
    echo "bwa samse -n 1 /lustre/beagle2/ReferenceSequences/Homo_sapiens/UCSC/hg19/Sequence/BWAIndex/genome.fa $inputDir/$toRemapFiles > $inputDir/$saiFile"
    echo "samtools view -S -b -q 10 $inputDir/$samFile  >  $inputDir/$remappedBamFile"
   
    #WASP:
    toRemapBam=$(echo "$1" | sed 's/bam/to\.remap\.bam/g')
    echo $toRemapBam
    remapkeepBam=$(echo "$1" | sed 's/bam/remap\.keep\.bam/g')
    echo $keepBam
    toremapNum=$(echo "$1" | sed 's/bam/to\.remap\.num\.gz/g')
    echo $toremapNum
    python $WASP/mapping/filter_remapped_reads.py -p $inputDir/$toRemapBam $inputDir/$remappedBamFile $inputDir/$remapkeepBam $inputDir/$toremapNum

    #merged bamfile:
    mergeBam=$(echo "$1" | sed 's/bam/merged\.bam/g')
    echo $mergeBam
    keepBam=$(echo "$1" | sed 's/bam/keep\.bam/g')
    echo "samtools merge $inputDir/$mergeBam $inputDir/$keepBam $inputDir/$remapkeepBam"
    mergedSorted= $(echo "$mergeBam" | sed 's/bam/sorted/g')
    echo $mergedSorted
    mergedSortedBam= $(echo "$mergeBam" | sed 's/bam/sorted\.bam/g')
    echo $mergedSortedBam
    samtools merge $inputDir/$mergeBam $inputDir/$keepBam $inputDir/$remapkeepBam
    samtools sort $inputDir/$mergeBam $inputDir/$mergedSorted
    samtools index $inputDir/$mergedSortedBam
    echo "samtools merge $inputDir/$mergeBam $inputDir/$keepBam $inputDir/$remapkeepBam"
    echo "samtools sort $inputDir/$mergeBam $inputdir/$mergedSorted"
    echo "samtools index $inputDir/$mergedSortedBam"

    #WASP:
    rmdupBam= $(echo "$1" | sed 's/bam/rmdup\.merged\.sorted\.bam/g')
    echo $rmdupBam
    python $WASP/mapping/rmdup.py $inputDir/$mergedSortedBam $inputDir/$rmdupBam
    
}


export -f FIND_SNPS

echo $bamFiles

# Check periodically for activity keep only my processes, once and hour for 20 hours
# to figure out whether we are reasonably load balanced
# NOTE: WHOAMI is exported from calling pbs script
#top -b -d 3600.00 -n 20 -u $WHOAMI >> ${destdir}/topLog.${runStamp} 2>&1 &

parallel -j $jobsPerNode  FIND_SNPS ::: $bamFiles  >>$plog 2>&1 


