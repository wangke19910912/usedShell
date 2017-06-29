#!/bin/sh

mail_robot()
{
    receivers="wangke3@xiaomi.com"
    echo ${2} | mail -s  ${1} ${receivers}
}

info()
{
    if [ $1 -ne 0 ]
    then
        mail_robot "Pipeline error Combined model" "$2 failed"
        exit -1
    fi
}

#HADOOP_HOME_LG=/usr/local/hbase_hadoop_hive/hive0.9-client-package-2014101403/hadoop
#HADOOP_HOME_C3=/home/work/tools/infra-client/bin/current/c3prc-hadoop-hadoop

day=`date -d "$1 days ago" +%Y%m%d`
print $day
flight="_new"
feature_data_path_cluster_cpc=/user/h_miui_ad/yanming/temp/daily_feature/date=${day}_CPC${flight}
#feature_data_path_cluster_cpd=/user/h_miui_ad/yanming/temp/daily_feature/date=${day}_CPD${flight}
feature_data_path_local_cpc='./data_CPC_'${day}

#hdfs_base_folder="/user/h_miui_ad/stream_ctr_prediction"
hdfs_base_folder="/user/h_miui_ad/ad_prediction_service_corpus/models"
online_model_cpc="model_combined_cpc"${flight}
online_model_cpd="model_combined_cpd"${flight}

model_lite_cpc='model_lite_cpc'${flight}'.txt'
model_old_cpc='model_old_cpc'${flight}'.txt'
model_lite_cpd='model_lite_cpd'${flight}'.txt'
model_old_cpd='model_old_cpd'${flight}'.txt'
model_cpc='model_cpc.txt'

echo "0-> Download Data"
if [ ! -d "$feature_data_path_local_cpc" ]; then
    hadoop fs -copyToLocal $feature_data_path_cluster_cpc $feature_data_path_local_cpc
fi
echo "1-> Train CPC"
#cp model_cpc${flight} model_cpc${flight}_old
#cat ${feature_data_path_local_cpc}/* | gzip -d | ./ftrl_train -im ${model_lite_cpc} -bias 1 -core 20 -l1 30
cat ${feature_data_path_local_cpc}/* | gzip -d | ./ftrl_train -m ${model_cpc} -bias 1 -core 20 -l1 30

#info $? "Combined model train error CPC"${flight}
#python model_lite.py model_cpc${flight} ${model_lite_cpc}
#cp model_cpc${flight} ${model_lite_cpc}

#echo "4-> Push model to HDFS CPC"
#echo "4.1-> Push model to LG HDFS"
#${HADOOP_HOME_LG}/bin/hadoop fs -cp -f ${hdfs_base_folder}/${online_model_cpc} ${hdfs_base_folder}/backup/${online_model_cpc}_${day}
#info $? "Combined model backup error CPC LG"${flight}
#${HADOOP_HOME_LG}/bin/hadoop fs -put -f ${model_lite_cpc} ${hdfs_base_folder}/${online_model_cpc}
#info $? "Combined model Push model to HDFS error CPC LG"${flight}

#echo "4.2-> Push model to C3 HDFS"
#${HADOOP_HOME_C3}/bin/hadoop fs -cp -f ${hdfs_base_folder}/${online_model_cpc} ${hdfs_base_folder}/backup/${online_model_cpc}_${day}
#info $? "Combined model backup error CPC C3"${flight}
#${HADOOP_HOME_C3}/bin/hadoop fs -put -f ${model_lite_cpc} ${hdfs_base_folder}/${online_model_cpc}
#info $? "Combined model Push model to HDFS error CPC C3"${flight}

