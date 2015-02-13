#!/bin/sh

#set -e

#如果需要设置目录信息,一定要在目录最后面加上分隔符

#设置环境变量(可编辑)
PATH=$PATH:/home/vagrant/.nvm/v0.10.33/bin

#设置应用名称,如果需要部署多个,可以添加数字,比如 messageserver-1 (可编辑)
APP_NAME="appname"
#应用所在目录(可编辑)
APP_PATH="/path/to/app"
#应用的文件名(可编辑)
APP_FILENAME="appfilename"
#应用的后缀名(可编辑)
APP_EXT="js"
#应用的文件名
APP_FILE=${APP_PATH}${APP_FILENAME}.${APP_EXT}

#PID文件存放目录,需保证目录可写(可编辑)
APP_PID_DIR="/home/vagrant/run/"
APP_PID_FILE="${APP_PID_DIR}${APP_NAME}.pid"

#应用守护进程信息(可编辑)
APP_DEAMON_PATH="/home/vagrant/.nvm/v0.10.33/bin/"
APP_DEAMON_BIN_FILE=${APP_DEAMON_PATH}supervisor
APP_DEAMON_ARGS="-w ${APP_PATH} -x node ${APP_FILE}"

#进程信息存放位置
APP_LOG_DIR="/home/vagrant/console/"
APP_LOG_FILE=${APP_LOG_DIR}${APP_NAME}

case "$1" in
  start)
        echo -n "Starting daemon: "$APP_NAME
	start-stop-daemon --start --quiet --pidfile $APP_PID_FILE --make-pidfile --exec $APP_DEAMON_BIN_FILE -- $APP_DEAMON_ARGS > ${APP_LOG_FILE}.out 2>${APP_LOG_FILE}.err &
        echo "."
	;;
  stop)
        echo -n "Stopping daemon: "$APP_NAME
	start-stop-daemon --stop --quiet --oknodo --pidfile $APP_PID_FILE
        echo "."
	;;
  restart)
        echo -n "Restarting daemon: "$APP_NAME
	start-stop-daemon --stop --quiet --oknodo --retry 30 --pidfile $APP_PID_FILE
	start-stop-daemon --start --quiet --pidfile $APP_PID_FILE --make-pidfile --exec $APP_DEAMON_BIN_FILE  -- $APP_DEAMON_ARGS > ${APP_LOG_FILE}.out 2>${APP_LOG_FILE}.err &
	echo "."
	;;

  *)
	echo "Usage: "$1" {start|stop|restart}"
	exit 1
esac

exit 0