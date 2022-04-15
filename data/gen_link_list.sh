#!/bin/bash
g++ -o preprocess preprocess.cpp -std=c++11
echo -e "${BIWhite}Generating link list data...${Color_Off}"

input_file_dir="/home/wftseng/li-sat-solver/sample_problems"
output_bcp_trace="/home/wftseng/eecs570_final/data/preprocessed_data_sorted/"

for i in 1 2 4 8 16
do
    for file in ${input_file_dir}/*.cnf
    do
        # ./sat.sh run $file $file".trace"
        output_file="$(basename "${file}")"
        output_file=$output_bcp_trace$i/"${output_file%.cnf}.linklist"
        echo "Input file: "$file
        echo "Output file: "$output_file
        ./preprocess $i $file $output_file
        # ./sat.sh compile 
        # ./sat.sh run $file $output_file
        # echo $file -ty
    done
done