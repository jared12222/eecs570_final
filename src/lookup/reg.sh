
TESTSET="../../data"

PROCESS_DIR="$TESTSET/preprocessed_data/*.cnf"
TRACE_DIR="$TESTSET/sat_trace"

RED='\033[0;031m'
NC='\033[0m'
GN='\033[0;032m'

LOGFILE="program.log"
rm $LOGFILE

for f in $PROCESS_DIR
do
    base=${f##*/}
    pref=${base%.*}
    echo "Processing $base"
    cp $f ./trace.cnf
    cp "$TRACE_DIR/$pref.out" ./trace.out
    if [[ $? -ne 0 ]]; then
        echo -e "[${RED}ERROR${NC}]${pref} NA" | tee -a $LOGFILE
        continue
    fi
    cntstr=$(./simv | grep Proc)
    #cntstr=$(cat program.out | grep Proc) # Debug
    cnt=${cntstr##*:}
    if [[ $? -ne 0 ]]; then
        echo -e "[${RED}LOG${NC}]" $pref $cnt | tee -a $LOGFILE
    else
        echo -e "[${GN}LOG${NC}]" $pref $cnt | tee -a $LOGFILE
    fi
    

done
