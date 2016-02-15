#!/bin/bash
# Author: SVM 
# Purpose: copy over RNAseq data and run WASP mapping pipeline
# USAGE: MasterScript.sh <variables> 

inputDir=$(readlink -f $1)
echo "Input files will be searched in " $inputDir

jobsPerNode=$2 #How many jobs per node = 1..32 what parallel gets 1-32 specific to Beagle
NNodes=$3 #Number of nodes you want to use /available (for 1000 files, and about 20 jobs/node only need 50 nodes)

outDir=$(readlink -f $4)

snpDir=$(readlink -f $5)
NCoresPerNode=32 #notchangeable

rundir=$PWD
#mkdir -p $OUTDIR

scriptName=$(basename ${0})
echo $scriptName
scriptName=${scriptName%\.sh}
echo $scriptName
scriptDir=$(readlink -f "$(dirname "$0")")
echo $scriptDir

timeTag=$(date "+%y_%m_%d_%H_%M_%S")

setup_log=${scriptName}_${LOGNAME}_${timeTag}.log
echo $setup_log
echo "RUNNING $scriptName as " $(readlink -f $0 ) " on " `date`  | tee  $setup_log

echo "Computation will run on  $NCoresPerNode cores per node " | tee -a $setup_log
echo "Each python file will be run on " $NNodes " Compute nodes" | tee -a $setup_log
echo "Total number of python jobs per node will be " $jobsPerNode | tee -a $setup_log


#list of input files
inputFiles=$(find $inputDir -name \*.saved.sequence.txt.gz | sort)
#want to grab directory and subdirectory of input files 
inputDirs=$( echo "$inputFiles" |              awk -F"/" '{print $(NF-2)"/"$(NF-1)}' | sort | uniq ) 
#grap root directory of input files
inputRoot=$( echo "$inputFiles" | head -n 1 |  awk -F"/" '{$(NF-2)=$(NF-1)=$NF=""; print $0 }' | tr ' ' '/' )

#Number of input files
NInputFiles=$(wc -w <<< "$inputFiles" )
echo "Running all " $NInputFiles " sequence files in $inputDir:" | tee -a $setup_log
filesPerNode=$(( ($NInputFiles+$NNodes-1)/$NNodes))
echo "Running  $filesPerNode sequence files per compute node for a total of " $(($filesPerNode*$NNodes))  | tee -a $setup_log
echo root of input files $inputRoot

#loop through directories to create directory structure and softlinks of input data in output directory
#and run pbs script that will run shell script to run python in parallel
nJobsInRun=0
nTotSubJobs=0
subFileList=""
for dir in $inputDirs;do
  echo "   $dir"
  mkdir -p "$outDir/$dir"
  for file in $(echo "$inputFiles"| grep $dir); do
      fileName=$dir/$(basename $file)
#create softlink for input files
     ln -s $file "$outDir/$dir"  
     nJobsInRun=$(($nJobsInRun+1))
     nTotSubJobs=$(($nTotSubJobs+1))
     if [ "$subFileList" ]; then
       subFileList="${subFileList}::${fileName}"
     else
       subFileList=$fileName
     fi
     echo $nJobsInRun $filesPerNode
     if [ "$nJobsInRun" -eq "$filesPerNode" ] || [ "$nTotSubJobs" -eq "$NInputFiles" ]; then
         echo $nJobsInRun $nTotSubJobs $subFileList
#Uncomment the following and jobs will be sent to the scheduler
	 qsub -v SEQFILES="$subFileList",JOBSPERNODE=$jobsPerNode,SCRIPTDIR=$scriptDir,SNPDIR=$snpDir,INPUTDIR=$outDir,NUM=$nJobsInRun -N $nJobsInRun $scriptDir/second.pbs 2>&1
	 echo -e "qsub -v SEQFILES=$subFileList,JOBSPERNODE=\"$jobsPerNode\",SCRIPTDIR=\"$scriptDir\",SNPDIR=\"$snpDir\" -N \"$nJobsInRun\" $scriptDir/second.pbs" | tee -a $setup_log
         nJobsInRun=0
         subFileList=""
	 exit
     fi    
  done
done | tee -a $setup_log
echo $NInputFiles

echo "Total number of nodes used will be " $(($NNodes))
echo "%%%" $(date) "$scriptName completed its execution " | tee -a $setup_log
