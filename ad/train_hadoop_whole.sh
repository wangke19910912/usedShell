#/bin/sh

data_path=$3
dir=`echo $data_path | rev | cut -d / -f 1 | rev`

echo $dir
old_model_name=ftrl_"$dir".new.model
new_model_name=ftrl_"$dir".old.model
log_name=ftrl_"$dir".log

echo new_model_name:$new_model_name
echo old_model_name:$old_model_name
echo log_name:$log_name
echo data_path:$data_path

for((i=$1;i<=$2;i++));
do
	read_path=${data_path}/date=201704${i}/*
	echo "prepare read from "$read_path 
        hadoop fs -test -e $read_path
	if [ 0 == $? ];then
		echo "read from "$read_path 
		if [ ! -f model/${old_model_name} ]; then  
			echo "old model file is not exist"
			hadoop fs -text $read_path | ./ftrl_train -m model/$new_model_name -bias 1 -core 20 -l1 30 > log/$log_name 2>&1 
			echo "copy new to old "
			mv model/$new_model_name model/$old_model_name
		else
			echo "old model file is exist"
			hadoop fs -text $read_path | ./ftrl_train -im model/$old_model_name -m model/$new_model_name -bias 1 -core 20 -l1 30 > log/$log_name 2>&1 
			echo "rm old model"
			rm model/$old_model_name
			echo "copy new to old "
			mv model/$new_model_name model/$old_model_name
		fi  
	fi

done
