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
normal_outputfiles=/user/h_a_ad/algo/wangke/browser_normal_dimension_feature2/date=${day}

hadoop --cluster c3prc-hadoop fs -rm -r ${normal_outputfiles}*

#main class
class=Job.GeneralFeatureExtractorWithNewsBehavior

echo "submit spark"

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
    $JAR_PATH $adInfoPath $userInfoPath $historicalInfoPath \
    $adEventPath $behaviorDataPath $normal_outputfiles
