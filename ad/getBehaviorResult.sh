#!/bin/sh

#source /home/work/.bashrc
#source /home/work/.bash_profile
#git pull
#mvn clean package -U
#set
#queue="a_recommendation"
#queue="root.default"
queue="root.production.a_group.a_ad.queue_1"
#queue="root.production.a_group.a_ad.queue_1"
num_executor="400"
master="yarn-cluster"
#master="local[*]"

#HADOOP_HOME="/home/work/tools/infra-client"
SPARK_HOME="/home/wangke/soft/infra-client"

#JAR path
JAR_PATH="/home/wangke/jars/feature_extractor-1.0-SNAPSHOT.jar"

#input path
day=`date -d "$1 days ago" +%Y%m%d`
hist_date=`date -d "$1 days ago" +%Y_%m_%d`
yy=`date -d "$1 days ago" +%Y`
mm=`date -d "$1 days ago" +%m`
dd=`date -d "$1 days ago" +%d`

echo $day
adInfoPath=/user/h_a_ad/ad_prediction_service_corpus/ad_corpus/ad_info_target_tag_emiv2
userInfoPath=/user/h_data_platform/platform/aads/a_ad_browser_dau_profile/date=${day}
historicalInfoPath=/user/h_a_ad/ad_prediction_service_corpus/history_corpus/${hist_date}*
adEventPath=/user/h_data_platform/platform/aads/a_ad_browser_ad_event/date=${day}
behaviorDataPath=/user/h_data_platform/platform/profile/recommend_user_info/date=${day}

while [ 1 == 1 ]
do    hadoop --cluster c3prc-hadoop fs -test -e ${behaviorDataPath}/_SUCCESS
    if [ $? == 0 ]
    then
        break
    fi    
    echo "File ${behaviorDataPath}/_SUCCESS not exist, wait"
    sleep 60
done

#output path
source_outputfiles=/user/h_a_ad/algo/wangke/BehaviorData/source
tag_outputfiles=/user/h_a_ad/algo/wangke/BehaviorData/tag
hadoop --cluster c3prc-hadoop fs -rm -r ${source_outputfiles}*
hadoop --cluster c3prc-hadoop fs -rm -r ${tag_outputfiles}*

#main class
class=Job.BehaviorData

echo "submit spark"

sampleRate=1
#/home/work/yanming/infra/infra-client/bin/spark-submit \
spark-submit \
    --cluster c3prc-hadoop \
    --class $class  \
    --master $master \
    --queue $queue \
    --conf spark.dynamicAllocation.enabled=true \
    --conf spark.shuffle.service.enabled=true \
    --conf spark.dynamicAllocation.minExecutors=20 \
    --conf spark.dynamicAllocation.maxExecutors=400 \
    $JAR_PATH $adInfoPath $userInfoPath $historicalInfoPath \
    $adEventPath $behaviorDataPath $source_outputfiles $tag_outputfiles \
    $sampleRate
