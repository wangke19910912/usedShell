#!/bin/bash
HBASE_HOME=/Users/wangke/work/software/hbase/hbase-1.0.2
FILE_RECORD=/Users/wangke/work/log/pkgs2.txt
TABLE_NAME=test
TABLE_COLUMN=f1:a

#从file中循环拼接执行命令行
cat $FILE_RECORD | while read rowkey 
do
  #GET操作,每次读取一列数据
  command="get '$TABLE_NAME','$rowkey',{COLUMNS=>'${TABLE_COLUMN}'}"
  echo $command
  output=`echo "${command}" | $HBASE_HOME/bin/hbase shell`
  
  status=$?
  if [[ "$status" = "0" ]]; then
   if [[ $output =~ .*value.* ]]; then
	result=`echo $output | awk '{n=match($0,/value/);value=substr($0,n,length($0));print value}'| awk '{value=substr($1,7,length($1));print value}'`
        echo "RESULT:"$result
   else
      echo "EMPTY RESULT!" 
   fi
  else
   echo "failed"$status  
  fi   
  

  #PUT操作
  #time=`date`
  #command="put '$TABLE_NAME','$rowkey','f1:a','$time'"
  #echo $command
  #echo "${command}" | $HBASE_HOME/bin/hbase shell > /dev/null 2>&1
  #status=$?
  #if [ "$status" = "0" ]; then
  #  echo "succeeded"
  #else
  #  echo "failed"$status
  #fi
done 
