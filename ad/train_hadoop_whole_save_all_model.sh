#/bin/sh
data_path=$1
loop_days=$2
loop_start=$3
old_model_name=$4

dir=`echo $data_path | rev | cut -d / -f 1 | rev`
process_id=ftrl_"$dir".id
prefix="_CPC_behavior"

echo $$ > log/$process_id
echo dir:$dir
echo data_path:$data_path 
echo old_model_name:$old_model_name
echo loop_days:$loop_days
echo loop_start:$loop_start

dates=`hadoop fs -ls  $data_path \
 | awk '{
        if(NR!=1){
              split($8,arr,"=");
              date=substr(arr[2],0,8);
              dates[date]=date
            }
        }
        END{l=asorti(dates);for(i=1;i<=l;i++)print dates[i]}    
        '`
echo ""

loop=0
start_loop_flg=False

for d in $dates
do
	if [ "$start_loop_flg" == False ];then
  	    if [ "$loop_start" != "" ]&&[ "$d" != "$loop_start" ];then
            	echo "skip $d,$loop_start not come..."
	    	continue;
	    else
		start_loop_flg=True
	    fi
	fi 
	
	if [ "$loop_days" != "" ];then
	    if [ "$loop" == "$loop_days" ];then
            	echo "already loop for $loop times"
	    	break;
            else
	    	let loop++
	    fi
	fi 

	hadoop_read_path=${data_path}/date=${d}${prefix}
	new_model_name=ftrl_"$dir"_${d}.model
	local_read_path=.tmp/$dir
	echo "start training $new_model_name"
	echo "prepare read from hadoop "$hadoop_read_path " to local" $local_read_path 
	rm -rf $local_read_path
	hadoop fs -copyToLocal $hadoop_read_path $local_read_path
	echo "end copy file from "$hadoop_read_path 

	if [ ! -f $local_read_path/_SUCCESS ];then
		echo "can not find $local_read_path/_SUCCESS file,training exit"
	  	exit 0 
        fi	

	if [ ! -f model/${old_model_name} ]; then  
		echo "old model file ${old_model_name} is not exist"
		echo "prepare training ${new_model_name}"
		cat $local_read_path/* | gzip -d | ./ftrl_train -m model/$new_model_name -bias 1 -core 20 -l1 30  
	else
		echo "old model file ${old_model_name} is found "
		echo "prepare training ${new_model_name},use old model ${old_model_name}"
		cat $local_read_path/* | gzip -d | ./ftrl_train -im model/$old_model_name -m model/$new_model_name -bias 1 -core 20 -l1 30  
	fi  
	rm -rf $local_read_path	
	echo "end training ${new_model_name}"
	old_model_name=${new_model_name}
	echo `date`
	echo ""

done
