#!/bin/sh

#source /home/work/.bashrc
#source /home/work/.bash_profile
#git pull
#mvn clean package -U
#set
#queue="miui_recommendation"
#queue="root.default"
queue="root.production.miui_group.miui_ad.queue_1"
#queue="root.production.miui_group.miui_ad.queue_1"
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

adInfoPath=/user/h_miui_ad/ad_prediction_service_corpus/ad_corpus/ad_info_target_tag_emiv2
userInfoPath=/user/h_data_platform/platform/miuiads/miui_ad_browser_dau_profile/date=${day}
historicalInfoPath=/user/h_miui_ad/ad_prediction_service_corpus/history_corpus/${hist_date}*
adEventPath=/user/h_data_platform/platform/miuiads/miui_ad_browser_ad_event/date=${day}
behaviorDataPath=/user/h_data_platform/platform/profile/recommend_user_info/date=${day}
behaviorTagPath=/user/h_miui_ad/algo/wangke/data/tag
behaviorSourcePath=/user/h_miui_ad/algo/wangke/data/source

while [ 1 == 1 ]
do
    hadoop --cluster c3prc-hadoop fs -test -e ${userInfoPath}
    if [ $? == 0 ]
    then
        break
    fi
    echo "File ${userInfoPath} not exist, wait"
    sleep 60
done

while [ 1 == 1 ]
do
    hadoop --cluster c3prc-hadoop fs -test -e ${adEventPath}
    if [ $? == 0 ]
    then
        break
    fi
    echo "File ${adEventPath} not exist, wait"
    sleep 60
done

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
normalOutputfiles=/user/h_miui_ad/algo/wangke/normal_dim_feature/date=${day}
highOutputfiles=/user/h_miui_ad/algo/wangke/high_dim_feature/date=${day}

hadoop --cluster c3prc-hadoop fs -rm -r ${normalOutputfiles}*
hadoop --cluster c3prc-hadoop fs -rm -r ${highOutputfiles}*


#main class
class=Job.GeneralTwoDimData

echo "submit spark"

fraction=0.3

spark-submit \
    --cluster c3prc-hadoop \
    --class $class --master $master \
    --num-executors $num_executor \
    --queue $queue --driver-memory 6g \
    --executor-memory 6g \
    --conf spark.dynamicAllocation.enabled=true \
    --conf spark.shuffle.service.enabled=true \
    --conf spark.dynamicAllocation.minExecutors=20 \
    --conf spark.dynamicAllocation.maxExecutors=400 \
    --conf spark.yarn.driver.memoryOverhead=896 \
    --conf spark.memory.fraction=0.3 \
    --conf spark.memory.storageFraction=0.3 \
    $JAR_PATH $adInfoPath $userInfoPath $historicalInfoPath \
    $adEventPath $behaviorDataPath $behaviorTagPath $behaviorSourcePath \
    $normalOutputfiles $highOutputfiles $fraction
