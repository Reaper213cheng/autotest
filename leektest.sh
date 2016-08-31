#!/bin/bash

  server=192.168.4.233
  leektestlogDir=~/workspace/share/log/leektest

  meminfolog()
  {
    
    adb shell procrank| head -n 1|tee -a $leektestlogDir/mediaproc.log
    adb shell procrank | grep mediaserver | tee -a $leektestlogDir/mediaproc.log
  }


  for i in $(seq 5)
  do 

    if [ $i = 1 ]; then 
        echo  "<-------播放开始之前，打印进程信息-------->" | tee -a $leektestlogDir/mediaproc.log
        meminfolog
    fi

    adb shell am start -n com.softwinner.TvdVideo/.TvdVideoActivity  -d http://$server/share/mp4/3.mp4

    sleep 5
      
    while true
    do
        string=`adb shell top -n 1 |grep TvdVideo |grep fg`

        if [ "$string" = "" ]; then 
      	   echo "<--------第$i次播放结束，打印进程信息--------->" |tee -a $leektestlogDir/mediaproc.log
      	   meminfolog 
           break
        fi

    done

  done
