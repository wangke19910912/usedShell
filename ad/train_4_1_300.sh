#!/bin/sh
source /home/wangke/.zshrc
kinit h_miui_ad@XIAOMI.HADOOP -k -t /home/wangke/soft/kerberos/h_miui_ad.keytab
path=/home/wangke/script

days=$1
today=`date -d "$days days ago" +%Y%m%d`
let days+=1
yesterday=`date -d "$days days ago" +%Y%m%d`

prefix=_CPC_behavior
high_outputfiles=/user/h_miui_ad/algo/wangke/browser_high_dimension_feature/date=${today}${prefix}
hadoop_model_path=ad_prediction_service_corpus/models
hadoop_model_name=model_4^1^300
local_model_path=$path/online
old_model_name=old_model.txt
new_model_name=new_model.txt
new_model_simpname=new_model_simple.txt

echo today:$today
#gen data
echo "start to execute $path/getBrowserHighDimensionFeature.sh 1"
sh $path/getBrowserHighDimensionFeature.sh $1
echo "end to execute $path/getBrowserHighDimensionFeature.sh 1"


hadoop --cluster c3prc-hadoop fs -test -e ${high_outputfiles}/_SUCCESS
if [ $? != 0 ]
then
    echo "File ${high_output_files}/_SUCCESS not exist,run spark"
    echo "start to execute $path/getBrowserHighDimensionFeature.sh $1"
    sh $path/getBrowserHighDimensionFeature.sh $1
    echo "end to execute $path/getBrowserHighDimensionFeature.sh $1"
    hadoop --cluster c3prc-hadoop fs -test -e ${high_outputfiles}/_SUCCESS
    if [ $? != 0 ]
    then   	
    	echo "fail to execute $path/getBrowserHighDimensionFeature.sh $1"
	exit 1
    fi
fi

#download old model
rm -f $local_model_path/$old_model_name
echo "copy model from  hadoop:$hadoop_model_path/$hadoop_model_name to local:$local_model_path/$old_model_name"
hadoop fs -copyToLocal $hadoop_model_path/$hadoop_model_name $local_model_path/$old_model_name


#train
rm -f $local_model_path/$new_model_name
echo "prepare train with $high_outputfiles/* use old model:$local_model_path/$old_model_name new model:$local_model_path/$new_model_name"
hadoop fs -text $high_outputfiles/* | $path/ftrl_train -im $local_model_path/$old_model_name -m $local_model_path/$new_model_name -bias 1 -core 20 -l1 30

#simply model
rm -f $local_model_path/$new_model_simpname
python $path/model_lite.py $local_model_path/$new_model_name $local_model_path/$new_model_simpname

#upload model online 
echo "upload from local:$local_model_path/$new_model_simpname to hadoop: $hadoop_model_path/$hadoop_model_name"
hadoop fs -copyFromLocal -f $local_model_path/$new_model_simpname $hadoop_model_path/$hadoop_model_name
exit 0
