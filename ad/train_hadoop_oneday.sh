#/bin/sh

data_path=$1
dir=`echo $data_path | rev | cut -d / -f 1 | rev`
dir1=$dir
dir=`echo $data_path | rev | cut -d / -f 2 | rev`_$dir

if [ $dir1 == "test" ] || [ $dir1 == "train" ]; then
    dir=`echo $data_path | rev | cut -d / -f 3 | rev`_$dir
fi

model_name=ftrl_"$dir".model
log_name=ftrl_"$dir".log

echo data_path:$data_path/*
echo model_name:$model_name
echo log_name:$log_name

nohup sh -c "hadoop fs -text $data_path/* | ./ftrl_train -m model/$model_name -bias 1 -core 20 -l1 30 > log/$log_name 2>&1"  >> log/nohup.log 2>&1 &

python model_lite.py model/$model_name model/$model_name.lite
