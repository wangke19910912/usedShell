#!/bin/sh

path=`pwd`
index=$1
while [ 1 == 1 ]
do
    if [ $index == $2 ]
    then
        break
    fi
    sh $path/getNormalDeminsionFeature.sh $index
    let index+=1
    sleep 1*60*60
done
