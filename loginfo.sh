#!/bin/bash



i=1
j=1
findkd()
{

	logname=$1

	kds="detect message coming"
	kde="set_raw_flag(card=1, raw_flag=1)"
	#back= "<CdxSockAsynRecv>force stop"

	##注意这个是正常播放后的检测
	tmp=`grep -n "prepare done" $logname|cut -d ':' -f1 `

	##以mediaserver进程打印的log为主
	#end=`grep -n "in onCompletion"  $logname|cut -d ':' -f1 `

	end=`grep -n "player notify eos"  $logname|cut -d ':' -f1 `


	#et=`grep -n "in onCompletion"  $logname|cut -d ' ' -f2 | head -n 1`
	et=`grep -n "player notify eos"  $logname|cut -d ' ' -f2 | head -n 1` 

	cat  $logname | head -n $end | tail -n +$tmp >tmp.log 
	logname=tmp.log 
	st=`grep -n "onInfo=====what=702==extra=0" tmp.log|cut -d ' ' -f2 | head -n 1`
	echo "<----------视频播放时间是从$st到$et---------->\n" |tee -a result.log

	tmp1=`grep -c "$kds" $logname`
	count=`expr $tmp1 - 1`
	echo "本次测试一共卡顿的次数为：$count\n"


	
	for i in $(seq "$count")
	do 
     	startL=`grep -n "$kds" $logname |cut -d ':' -f1 | head -n 1`
     	startT=`grep -n "$kds" $logname |cut -d ' ' -f2 | head -n 1`
     	#echo "$logname"

     	if [ $i = 1 ];	then
     		cat $logname |tail -n +$startL >$j.log
     		logname=$j.log
     		echo "$logname"
     	fi

     	#echo "退出if语句后的日志名字为：$logname"

     	endL=`grep -n "$kde" $logname |cut -d ':' -f1 | head -n 1 `
     	endT=`grep -n "$kde" $logname |cut -d ' ' -f2 | head -n 1`
     	echo "第$i次卡顿,卡顿时间是从到$startT到$endT" |tee -a result.log
     	endL=`expr $endL + 1`
     	k=$j
     	j=`expr $j + 1`
     	#j=$((j+1))
     	cat $logname |tail -n +$endL >$j.log
     	logname=$j.log
     	rm $k.log
	done
    rm $j.log
    rm tmp.log
}  


logfilter()
{
   	IoStr=`grep -n  "DEMUX_ERROR_IO" $1`

   	if  [ -n "$IoStr" ];	then  

   		echo  "播放器发生IO错误，视频播放失败"
   		grep -n -A5 -B5 "DEMUX_ERROR_IO" $1 >IOEor.log   

    else 
       	FlStr= `grep -n "Fatal signal" $1`

  		  if [ -n "$FlSrt"  ] ;	then  
        	 echo  "播放器程序崩溃！！！"
        	 grep -n A3 -B5  "Fatal signal" $1 >FatalEor.log
         
        else
        	 echo "片源正常播放！"  
        	 findkd $1
  		  fi 

  	fi

}


logfilter _http_allVideosTest_1.mp4.log
  


 


