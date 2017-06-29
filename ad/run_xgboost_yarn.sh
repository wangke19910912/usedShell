#!/bin/sh

#source /home/work/.bashrc
#source /home/work/.bash_profile
#git pull
#mvn clean package -U
#set
#queue="a_recommendation"
queue="root.default"
#queue="root.service.a_group.a_ad"
num_executor="1"
#master="yarn-client"
master="local[*]"

SPARK_HOME="/home/wangke/soft/infra-client"

#JAR path
JAR_PATH="/home/wangke/jars/feature_extractor-1.0-SNAPSHOT.jar"
export PYSPARK_PYTHON=/opt/soft/anaconda2/bin/python



#execute date
day=`date -d "4 days ago" +%Y%m%d`
echo $day
#output path
#trainData=/user/h_a_ad/wangke/daily_feature/date=${day}_CPC_client
#trainData=/user/h_a_ad/wangke/index_data/Test2.data
trainData=/user/h_a_ad/wangke/daily_feature/date=20170413/part-00999
modelPath=/user/h_a_ad/wangke/model

hadoop --cluster c3prc-hadoop fs -rmr ${modelPath}*

#main class
class=Job.GeneralFeatureAssemble

echo "prepare submit spark"


#/home/work/yanming/infra/infra-client/bin/spark-submit \
spark-submit \
    --cluster c3prc-hadoop-spark2.0\
    --class $class --master $master \
    --num-executors $num_executor \
    --queue $queue --driver-memory 6g \
    --executor-memory 6g \
    --conf spark.dynamicAllocation.enabled=true \
    --conf spark.shuffle.service.enabled=true \
    --conf spark.yarn.driver.memoryOverhead=896 \
    --conf spark.memory.fraction=0.3 \
    --conf spark.yarn.appMasterEnv.PYSPARK_DRIVER_PYTHON=/opt/soft/anaconda2/bin/python \
    --conf spark.yarn.appMasterEnv.PYSPARK_PYTHON=/opt/soft/anaconda2/bin/python \
    --conf spark.yarn.maxAppAttempts=1 \
    $JAR_PATH $trainData $modelPath
