#!/bin/sh

path=`pwd`
cd $path
index=$1
while [ 1 == 1 ]
do
    if [ $index == $2 ]
    then
        break
    fi
    python run_xgboost_small.py  > log/xgboost_log.txt 2>&1 &
    let index+=1
    sleep 1*60*60
done
