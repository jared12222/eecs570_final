#!/bin/bash
g++ -o opt_analysis opt_analysis.cpp -std=c++11
echo -e "${BIWhite}Generating opt_analysis...${Color_Off}"

input_file_dir="/home/wftseng/eecs570_final/data/preprocessed_data"
input_file_trace="/home/wftseng/eecs570_final/data/sat_trace"

for i in 1 2 4 8 16
do
    for file in ${input_file_dir}/$i/*.linklist
    do
        # ./sat.sh run $file $file".trace"
        # output_file="$(basename "${file}")"
        # output_file=$output_bcp_trace$i/"${output_file%.cnf}.linklist"
        file_basename="$(basename "${file}")"
        file_basename="${file_basename%.*}"
        input_file_dir_sorted=${input_file_dir}"_sorted/"$i/$file_basename".linklist"
        trace_file=${input_file_trace}/$file_basename".trace"
        echo "Input file: "$file
        echo "Input file sorted: "$input_file_dir_sorted

        echo "Input file trace: "$trace_file
        ./opt_analysis $file $input_file_dir_sorted $trace_file
        # ./preprocess $i $file $output_file
        # ./sat.sh compile 
        # ./sat.sh run $file $output_file
        # echo $file -ty
    done
done