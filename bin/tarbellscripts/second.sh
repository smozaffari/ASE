#!/bin/bash
#PBS -N second
#PBS -e second.err
#PBS -o second.log
#PBS -M smozaffari@uchicago.edu
#PBS -m abe

cd $PBS_O_WORKDIR
echo $PBS_O_WORKDIR

module load bwa
module load samtools
module load parallel

umask 022

echo "%%% Begin at " $(date)
export WHOAMI=$(whoami)
echo "Submitted as:" $WHOAMI
echo "running jobs in "$PWD
echo "$SCRIPTDIR"
echo "$BAMFILES"
echo "$JOBSPERNODE"
echo "$INPUTDIR"

export $SNP_DIR
export $INPUTDIR
$NUM
export WASP=/group/ober-resources/users/smozaffari/ASE/bin/scripts/WASP

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

echo SCRIPTDIR $SCRIPTDIR
BAMFILES=$(echo $BAMFILES | sed 's/::/\ /g')

# make the script verbose

# functions to be used in the call to parallels
FIND_SNPS() {
    #first part of WASP:
    python $WASP/mapping/find_intersecting_snps.py $INPUTDIR/$1 $SNP_DIR
    
    base=$(echo "$1" | sed 's/\.bam//g')
    #remap files:
    bwa aln -n 2 -N /group/referenceFiles/Homo_sapiens/UCSC/hg19/Sequence/IlluminaBWAIndex/genome.fa $INPUTDIR/${base}.remap.fq.gz > $INPUTDIR/${base}.sai              
    bwa samse -n 1 /group/referenceFiles/Homo_sapiens/UCSC/hg19/Sequence/IlluminaBWAIndex/genome.fa $INPUTDIR/${base}.sai $INPUTDIR/${base}.remap.fq.gz > $INPUTDIR/${base}.sam    
    samtools view -S -b -h -q 10 $INPUTDIR/${base}.sam >  $INPUTDIR/${base}.remap.bam


    #WASP:
    python $WASP/mapping/filter_remapped_reads.py $INPUTDIR/${base}.to.remap.bam $INPUTDIR/${base}.remap.bam $INPUTDIR/${base}.remap.keep.bam $INPUTDIR/${base}.to.remap.num.gz
    echo "python $WASP/mapping/filter_remapped_reads.py $INPUTDIR/${base}.to.remap.bam $INPUTDIR/${base}.remap.bam $INPUTDIR/${base}.remap.keep.bam $INPUTDIR/${base}.to.remap.num.gz"

    #merged bamfile:
    samtools merge $INPUTDIR/${base}.keep.merged.bam $INPUTDIR/${base}.keep.bam $INPUTDIR/${base}.remap.keep.bam
    samtools sort $INPUTDIR/${base}.keep.merged.bam $INPUTDIR/${base}.keep.merged.sorted
    samtools index $INPUTDIR/${base}.keep.merged.sorted.bam
    echo "samtools merge $INPUTDIR/${base}.keep.merged.bam $INPUTDIR/${base}.keep.bam $INPUTDIR/${base}.remap.keep.bam"
    echo "samtools sort $INPUTDIR/${base}.keep.merged.bam $INPUTDIR/${base}.keep.merged.sorted"
    echo "samtools index $INPUTDIR/${base}.keep.merged.sorted.bam"

    #WASP:
    python $WASP/mapping/rmdup.py $INPUTDIR/${base}.keep.merged.sorted.bam $INPUTDIR/${base}.keep.rmdup.merged.sorted.bam
    
}


export -f FIND_SNPS

echo $BAMFILES

# Check periodically for activity keep only my processes, once and hour for 20 hours
# to figure out whether we are reasonably load balanced
# NOTE: WHOAMI is exported from calling pbs script
#top -b -d 3600.00 -n 20 -u $WHOAMI >> ${destdir}/topLog.${runStamp} 2>&1 &

parallel -j $JOBSPERNODE  FIND_SNPS ::: $BAMFILES  >>$plog 2>&1 


