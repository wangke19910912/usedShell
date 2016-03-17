#!/bin/bash
HBASE_HOME=/Users/wangke/work/software/hbase/hbase-1.0.2
FILE_RECORD=/Users/wangke/work/log/pkgs.txt
OUTPUT_RECORD=/Users/wangke/work/log/output.txt

#将put命令重新组装放入文件中
#cat $FILE_RECORD | while read line
#do
#  newline="put 'miui_sec_auth_permission','abc','del','${line}'"
#  echo $newline >> $OUTPUT_RECORD  
#done

#使用客户端将命令进行执行
RECORDS=`cat $OUTPUT_RECORD` 
echo "start put into hbase...."
exec $HBASE_HOME/bin/hbase shell <<EOF
cat $RECORDS
EOF
