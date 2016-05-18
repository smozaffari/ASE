#!/bin/bash
# Script that will be executed on the compute nodes

. /opt/modules/default/init/bash
if [ ! $(module list -t 2>&1 | grep PrgEnv-gnu) ]; then
 module swap PrgEnv-cray PrgEnv-gnu
fi

export PATH="/lustre/beagle2/ober/users/smozaffari/miniconda2/bin:$PATH"

module load bcftools

module load samtools/1.2

dir="/lustre/beagle2/ober/users/smozaffari/ASE/results"
file=$1
echo $file 

newfile=$( echo "$file" | cut -f4 -d"/" );
echo $newfile; 
id=$( echo "$newfile" | cut -f1 -d".");
echo $id
outfile=$( echo "$newfile" | sed 's/keep.merged.sorted.bam/total.reads.txt/g');
echo $outfile

flowcell=$( echo "$file" | cut -f2 -d"/");
echo $flowcell
outfiletemp2=$( echo "$newfile" | sed 's/keep.merged.sorted.bam/total.temp.txt/g');
echo $outfiletemp2
outfiletemp="${flowcell}_${outfiletemp2}"
echo $outfiletemp

outfile2="${flowcell}_${outfile}"
echo $outfile2


tx="$dir/gene_start_stop_noNONE.txt"
echo $tx

outdir="$dir/nosnp_reads"

#echo "samtools index $dir/$file"
#samtools index $dir/$file 
#txlines=`cat $tx`

#for line in $filelines ; do
cat $tx | while read line ; do
    echo $line 
    c=( $line )
    chr="${c[1]}:${c[2]}-${c[3]}" 
    write="${c[0]} : $chr :"
    echo $write >> $outfiletemp
    echo "samtools view $dir/$file $chr | wc -l >>$outfiletemp"
    samtools view $dir/$file $chr | wc -l >>$outfiletemp
done

sed 'N;s/\n/ /' $outfiletemp > $outdir/$outfile2

rm $outfiletemp