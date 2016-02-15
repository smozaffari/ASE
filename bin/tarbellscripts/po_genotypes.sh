#!/bin/bash -x

# to submit this, enter './adaptor_list_through.sh' 
# the read command is going to look at whatever file you pipe into the script with the < operator
while read LINE; do
	echo "$LINE"
  cat "HUTTERITES ${LINE}2" > ${LINE}2.txt
  cat "HUTTERITES ${LINE}1" > ${LINE}1.txt
	echo "qsub -v FINDIV=$LINE geno.pbs"
	# qsub -v FINDIV=$LINE geno.pbs
done < /group/ober-resources/users/smozaffari/ASE/data/findivlist
