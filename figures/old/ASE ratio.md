cat star/FlowCell10/106052/106052_lane_4_ASE_info >>both_106052 

cut -f1-4 -d" " both_106052 | grep -v D7L | sort | uniq -c | grep -v problem | sed 's/^ *//'  | awk '{ print $1, $2, $3, $4, $5, "106052" }' > 106052_both_ASE_info 
