#!/bin/bash

# Licence: GPLv3, MIT, BSD, Apache or whatever you prefer; FREE to use, modify, copy, no obligations
# Description: Bash Script to Start the process with NOHUP and & - in background, pretend to be a Daemon
# Author: Andrew Bikadorov
# Script v1.5

# For debugging purposes uncomment next line
#set -x

#如果需要设置目录信息,一定要目录最后面加上分隔符

#设置环境变量(可编辑)
PATH=$PATH:/home/vagrant/.nvm/v0.10.33/bin

#应用名称,如果是多台服务器就采用名称加数字的形式进行命名,比如 messageserver-1 (可编辑)
APP_NAME="appname"
#应用的文件名(可编辑)
APP_FILENAME="appfilename"
#应用pid文件存放位置,需保证目录可写(可编辑)
APP_PID_DIR="/home/vagrant/run/"
#应用的pid文件
APP_PID="${APP_PID_DIR}${APP_NAME}.pid"
#应用所在目录(可编辑)
APP_PATH="/path/to/app/"
#应用扩展名(可编辑)
APP_FILE=$APP_FILENAME".js"
#应用标准输出文件目录，保证可写(可编辑)
APP_LOGS="/home/vagrant/console/"
#需要执行的命令
APP_PRE_OPTION="supervisor -w ${APP_PATH} -x node"
APP_POST_OPTION=""

# Should Not Be altered
TMP_FILE="/tmp/status_${APP_NAME}"
### For internal usage
STATUS_CODE[0]="Is Running"
STATUS_CODE[1]="Not Running"
STATUS_CODE[2]="Stopped incorrectly"
STATUS_CODE[9]="Default Status, should not be seen"

start() {
    
    checkpid
	STATUS=$?
	if [ $STATUS -ne 0 ] ;
    then
		echo "Starting $APP_NAME..."
		## java –jar $APP_PATH/ghost.jar
		nohup $APP_PRE_OPTION $APP_PATH/$APP_FILE $APP_POST_OPTION > $APP_LOGS/$APP_NAME.out 2> $APP_LOGS/$APP_NAME.err < /dev/null &
		# You can un-comment next line to see what command is exactly executed
		# echo "nohup $APP_PRE_OPTION $APP_PATH/$APP_FILE $APP_POST_OPTION > $APP_LOGS/$APP_FILENAME.out 2> $APP_LOGS/$APP_FILENAME.err < /dev/null &"
		echo PID $!
		echo $! > $APP_PID
		
		statusit
		#echo "Done"
    else
		echo "$APP_NAME Already Running"
    fi
}

stop() {
    checkpid
	STATUS=$?
	if [ $STATUS -eq 0 ] ;
	then
		echo "Stopping $APP_NAME..."
		kill `cat $APP_PID`
		rm $APP_PID
		statusit
		#echo "Done"
	else
		echo "$APP_NAME - Already killed"
	fi
}

checkpid(){
    STATUS=9
    
    if [ -f $APP_PID ] ;
	then
		#echo "Is Running if you can see next line with $APP_NAME"
		ps -Fp `cat $APP_PID` | grep $APP_FILE > $TMP_FILE
		if [ -f $TMP_FILE -a -s $TMP_FILE ] ;
			then
				STATUS=0
				#"Is Running (PID `cat $APP_PID`)"
			else
				STATUS=2
				#"Stopped incorrectly"
			fi
		
		## Clean after yourself	
		rm -f $TMP_FILE
	else
		STATUS=1
		#"Not Running"
	fi
	
	return $STATUS
}

statusit() {
	#TODO
    #status -p $APP_PID ghost
    checkpid
    #GET return value from previous function
	STATUS=$?
	#echo $?
	
	EXITSTATUS=${STATUS_CODE[STATUS]}
	
	if [ $STATUS -eq 0 ] ;
	then
		EXITSTATUS=${STATUS_CODE[STATUS]}" (PID `cat $APP_PID`)"
	fi
    
	#echo "First Index: ${NAME[0]}"
	#echo "Second Index: ${NAME[1]}"
	
    echo $APP_NAME - $EXITSTATUS
    #${STATUS_CODE[STATUS]}
    
}



case "$1" in

    'start')
        start
        ;;

    'stop')
        stop
        ;;

    'restart')
        stop
        start
        ;;

    'status')
        statusit
        ;;
        
    *)
        echo "Usage: $0 { start | stop | restart | status }"
        exit 1
        ;;
esac

exit 0
