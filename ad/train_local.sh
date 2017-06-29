#/bin/sh

data_path=$1
type=`echo $data_path | rev | cut -d / -f 1 | rev`
dir_1=`echo $data_path | rev | cut -d / -f 2 | rev`
dir_2=`echo $data_path | rev | cut -d / -f 3 | rev`

model_name=ftrl_"$dir_1"_"$dir_2"_"$type".model
log_name=ftrl_"$dir_1"_"$dir_2"_"$type".log

echo model_name:$model_name
echo log_name:$log_name

nohup sh -c "cat $data_path/* |gzip -d | ./ftrl_train -m model/$model_name -bias 1 -core 20 -l1 30 > log/$log_name 2>&1"  >> log/nohup.log 2>&1 &
