#!/bin/bash -x
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

# make the script verbose
set -x

# functions to be used in the call to parallels
FIND_SNPS() {
    set -x
    #first part of WASP:
    python $WASP/mapping/find_intersecting_snps.py $inputDir/$1 $SNP_DIR
    
    base=$(echo "$1" | sed 's/\.bam//g')
    #remap files:
    bwa aln -n 2 -N /group/referenceFiles/Homo_sapiens/UCSC/hg19/Sequence/IlluminaBWAIndex/ $inputDir/${base}.remap.fq.gz > $inputDir/${base}.sai              
    bwa samse -n 1 /group/referenceFiles/Homo_sapiens/UCSC/hg19/Sequence/IlluminaBWAIndex/ $inputDir/${base}.sai $inputDir/${base}.remap.fq.gz > $inputDir/${base}.sam    
    samtools view -S -b -h -q 10 $inputDir/${base}.sam >  $inputDir/${base}.remap.bam
    samtools view -S -h -f 4 -b $inputDir/${base}.sam > $inputDir /${base}.unremap.bam
#    bwa aln -n 1 /lustre/beagle2/ober/users/smozaffari/files_from_Darren/all_junctions.50.ens.eedb -b0 $inputDir/${base}.unremap.bam > $inputDir/${base}.junction.ref.sai
#    bwa samse -n 1 /lustre/beagle2/ober/users/smozaffari/files_from_Darren/all_junctions.50.ens.eedb $inputDir/${base}.junction.ref.sai $inputDir/${base}.unremap.bam > $inputDir/${base}.junction.ref.sam
#    samtools view -S -h -q 10 -b $inputDir/${base}.junction.ref.sam > $inputDir/${base}.junction.quality.bam
#    samtools sort $inputDir/${base}.junction.quality.bam $inputDir/${base}.junction.quality.sort
#    samtools merge merged.unsorted.bam $inputDir/${base}.junction.quality.bam $inputDir/${base}.remap.bam 
#    samtools merge merged.sorted.bam $inputDir/${base}.junction.quality.sort.bam $inputDir/${base}.remap.sort.bam 


#    echo "bwa aln -n 2 -N /lustre/beagle2/ReferenceSequences/Homo_sapiens/UCSC/hg19/Sequence/BWAIndex/genome.fa $inputDir/${base}.remap.fq.gz > $inputDir/${base}.sai"
#    echo "bwa samse -n 1 /lustre/beagle2/ReferenceSequences/Homo_sapiens/UCSC/hg19/Sequence/BWAIndex/genome.fa $inputDir/${base}.sam $inputDir/${base}.remap.fq.gz > $inputDir/${base}.sam"
#    echo "samtools view -S -b -q 10 $inputDir/${base}.sam >  $inputDir/${base}.remap.bam"
    sleep 2m

    #WASP:
    python $WASP/mapping/filter_remapped_reads.py $inputDir/${base}.to.remap.bam $inputDir/${base}.remap.bam $inputDir/${base}.remap.keep.bam $inputDir/${base}.to.remap.num.gz
    echo "python $WASP/mapping/filter_remapped_reads.py $inputDir/${base}.to.remap.bam $inputDir/${base}.remap.bam $inputDir/${base}.remap.keep.bam $inputDir/${base}.to.remap.num.gz"

    #merged bamfile:
    samtools merge $inputDir/${base}.keep.merged.bam $inputDir/${base}.keep.bam $inputDir/${base}.remap.keep.bam
    samtools sort $inputDir/${base}.keep.merged.bam $inputDir/${base}.keep.merged.sorted
    samtools index $inputDir/${base}.keep.merged.sorted.bam
    echo "samtools merge $inputDir/${base}.keep.merged.bam $inputDir/${base}.keep.bam $inputDir/${base}.remap.keep.bam"
    echo "samtools sort $inputDir/${base}.keep.merged.bam $inputDir/${base}.keep.merged.sorted"
    echo "samtools index $inputDir/${base}.keep.merged.sorted.bam"

    #WASP:
    python $WASP/mapping/rmdup.py $inputDir/${base}.keep.merged.sorted.bam $inputDir/${base}.keep.rmdup.merged.sorted.bam
    rmdupBam= $(echo "$1" | sed 's/bam/keep\.rmdup\.merged\.sorted\.bam/g')
#    python $WASP/mapping/rmdup.py $inputDir/$mergedSortedBam $inputDir/$rmdupBam
    
}


export -f FIND_SNPS

echo $bamFiles

# Check periodically for activity keep only my processes, once and hour for 20 hours
# to figure out whether we are reasonably load balanced
# NOTE: WHOAMI is exported from calling pbs script
#top -b -d 3600.00 -n 20 -u $WHOAMI >> ${destdir}/topLog.${runStamp} 2>&1 &

parallel -j $jobsPerNode  FIND_SNPS ::: $bamFiles  >>$plog 2>&1 


