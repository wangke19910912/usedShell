#!/bin/bash
result_file=$1
auc_result_file=`echo $result_file | rev | cut -d / -f 1 | rev`.auc
auc_log_file=`echo $result_file | rev | cut -d / -f 1 | rev`.auc.log

echo result_file: $result_file
echo auc_result_file: $auc_result_file
echo auc_log_file: $auc_log_file
nohup sh -c "cat $result_file | python AUC.py > result/$auc_result_file " > log/$auc_log_file 2>&1 &

