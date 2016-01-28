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
    echo "remappedfiles filenames made"
    bwa aln -n 2 -N /lustre/beagle2/ReferenceSequences/Homo_sapiens/UCSC/hg19/Sequence/BWAIndex/genome.fa $inputDir/$toRemapfqFiles > $inputDir/$saiFile
    bwa samse -n 1 /lustre/beagle2/ReferenceSequences/Homo_sapiens/UCSC/hg19/Sequence/BWAIndex/genome.fa $inputDir/$saiFile $inputDir/$toRemapfqFiles > $inputDir/$samFile
    samtools view -S -b -q 10 $inputDir/$samFile >  $inputDir/$remappedBamFile
    echo "bwa aln -n 2 -N /lustre/beagle2/ReferenceSequences/Homo_sapiens/UCSC/hg19/Sequence/BWAIndex/genome.fa $inputDir/$toRemapFiles > $inputDir/$saiFile"
    echo "bwa samse -n 1 /lustre/beagle2/ReferenceSequences/Homo_sapiens/UCSC/hg19/Sequence/BWAIndex/genome.fa $inputDir/$toRemapFiles > $inputDir/$saiFile"
    echo "samtools view -S -b -q 10 $inputDir/$samFile  >  $inputDir/$remappedBamFile"
   
    echo "all the bwa stuff worked"
    #WASP:
    toRemapBam=$(echo "$1" | sed 's/bam/to\.remap\.bam/g')
    echo $toRemapBam
    remapkeepBam=$(echo "$1" | sed 's/bam/remap\.keep\.bam/g')
    echo $keepBam
    toremapNum=$(echo "$1" | sed 's/bam/to\.remap\.num\.gz/g')
    echo $toremapNum
    echo "wasp files made"
    python $WASP/mapping/filter_remapped_reads.py $inputDir/$toRemapBam $inputDir/$remappedBamFile $inputDir/$remapkeepBam $inputDir/$toremapNum
    echo "filter remapped reads worked"

    #merged bamfile:
    keepmergeBam=$(echo "$1" | sed 's/bam/keep\.merged\.bam/g')
    echo $keepmergeBam
    keepBam=$(echo "$1" | sed 's/bam/keep\.bam/g')
    echo $keepBam
    samtools merge $inputDir/$keepmergeBam $inputDir/$keepBam $inputDir/$remapkeepBam
    echo "samtools merge $inputDir/$keepmergeBam $inputDir/$keepBam $inputDir/$remapkeepBam"

    mergedSorted= $(echo "$1" | sed 's/bam/keep\.merged\.sorted/g')
    echo $mergedSorted
    samtools sort $inputDir/$mergeBam $inputDir/$mergedSorted
    echo "samtools sort $inputDir/$keepmergeBam $inputDir/$mergedSorted"

    mergedSortedBam= $(echo "$1" | sed 's/bam/keep\.merged\.sorted\.bam/g')
    echo $mergedSortedBam
    echo "make merged bam files"
    samtools index $inputDir/$mergedSortedBam
    echo "samtools index $inputDir/$mergedSortedBam"

    #WASP:
    rmdupBam= $(echo "$1" | sed 's/bam/keep\.rmdup\.merged\.sorted\.bam/g')
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


