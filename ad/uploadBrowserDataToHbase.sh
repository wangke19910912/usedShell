#!/bin/sh
source /home/wangke/.zshrc
kinit h_miui_ad@XIAOMI.HADOOP -k -t /home/wangke/soft/kerberos/h_miui_ad.keytab
#source /home/work/.bashrc
#source /home/work/.bash_profile
#git pull
#mvn clean package -U
#set
#queue="miui_recommendation"
#queue="root.default"
queue="root.production.miui_group.miui_ad.queue_1"
master="yarn-cluster"
#master="local[*]"

#HADOOP_HOME="/home/work/tools/infra-client"
SPARK_HOME="/home/wangke/soft/infra-client"
path=/home/wangke/script

#JAR path
JAR_PATH="/home/wangke/jars/miui_ad_ctr_data-1.0-SNAPSHOT.jar"

#input path
day=`date -d "$1 days ago" +%Y%m%d`
hist_date=`date -d "$1 days ago" +%Y_%m_%d`
yy=`date -d "$1 days ago" +%Y`
mm=`date -d "$1 days ago" +%m`
dd=`date -d "$1 days ago" +%d`

echo $day
adInfoPath=/user/h_miui_ad/ad_prediction_service_corpus/ad_corpus/ad_info_target_tag_emiv2
behaviorDataPath=/user/h_data_platform/platform/profile/recommend_user_info/date=${day}
behaviorTagPath=/user/h_miui_ad/ad_prediction_service_corpus/browser_history_tags/tag
behaviorSourcePath=/user/h_miui_ad/ad_prediction_service_corpus/browser_history_tags/source
dauDataPath=/user/h_data_platform/platform/miuiads/miui_ad_browser_dau/date=${day}

#output path
high_outputfiles=/user/h_miui_ad/algo/wangke/hbase_test/date=${day}

hadoop --cluster c3prc-hadoop fs -rm -r ${high_outputfiles}*

#main class
class=com.xiaomi.miui.ad.ctr.job.NewsBehaviorUploadJob

echo "submit spark"


#NOTE:driver conf must conf in this file 
spark-submit \
    --cluster c3prc-hadoop \
    --class $class  \
    --master $master \
    --queue $queue \
    --driver-memory 6g \
    --executor-memory 6g \
    --hbase "hbase://c3miuisrv-adsctr" \
    --files $path/conf/core-site.xml,$path/conf/hbase-site.xml,$path/conf/h_miui_ad.keytab \
    --conf spark.yarn.driver.memoryOverhead=2048 \
    --conf spark.dynamicAllocation.enabled=true \
    --conf spark.shuffle.service.enabled=true \
    --conf spark.dynamicAllocation.minExecutors=20 \
    --conf spark.dynamicAllocation.maxExecutors=400 \
    --conf spark.memory.fraction=0.3 \
    $JAR_PATH $dauDataPath \
    $behaviorDataPath $behaviorTagPath \
    $behaviorSourcePath $high_outputfiles
