#/bin/sh

model_path=$1
data_path=$2

type=`echo $data_path | rev | cut -d / -f 1 | rev`
dir=`echo $data_path | rev | cut -d / -f 2 | rev`
model_name=`echo $model_path | rev | cut -d / -f 1 | rev`

result_name=predict_"$model_name"__"$dir"_"$type".result
log_name=predict_"$dir"_"$type".log

echo hdfs_path:$data_path/*
echo model_path:$model_path
echo model_name:$model_name
echo result_name:$result_name
echo log_name:$log_name

nohup sh -c "hadoop fs -text $data_path/* | ./ftrl_predict $model_path 20 result/$result_name >> log/$log_name 2>&1"  >> log/nohup.log 2>&1 &
