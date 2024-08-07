#!/bin/bash
r文件，提供启动，停止，重启等功能
# 需要根据jar包名称更改APP_JAR
# ms 和 mx 也需要根据情况调整

SHELL_FOLDER=$(cd "$(dirname "$0")";pwd)
APP_JAR="idp-log.jar"
LOG_PATH=$SHELL_FOLDER/logs
JAVA_OPTS="
-server
-Xms128m 
-Xmx128m
-XX:+AlwaysPreTouch 
-XX:+PrintGCDetails 
-Xloggc:$LOG_PATH/gc.log 
-XX:+HeapDumpOnOutOfMemoryError 
-XX:HeapDumpPath=$LOG_PATH/heapdump
-Dfile.encoding=utf-8"

start(){
  if [ ! -d "$LOG_PATH"  ];then
    mkdir "$LOG_PATH"
  fi
  nohup java -javaagent:/opt/idp4.0/apache-skywalking-apm-bin-es7/agent/skywalking-agent.jar -Dskywalking.agent.service_name=keeper-log -Dskywalking.collector.backend_service=10.0.202.150:11800  $JAVA_OPTS -jar $SHELL_FOLDER/$APP_JAR --server.port=5117 --spring.cloud.nacos.discovery.server-addr=10.0.202.150:8848 --spring.cloud.nacos.config.server-addr=10.0.202.150:8848 --spring.cloud.nacos.config.username=nacos --spring.cloud.nacos.config.password=nacos --spring.cloud.nacos.discovery.username=nacos --spring.cloud.nacos.discovery.password=nacos >$LOG_PATH/console.log 2>&1 & 
  echo "app $SHELL_FOLDER/$APP_JAR started."
  echo "JAVA_OPTS: $JAVA_OPTS"
}

stop(){
    ps -ef|grep $SHELL_FOLDER/$APP_JAR|grep -v grep|awk '{print $2}'|xargs kill -9
    echo "app $SHELL_FOLDER/$APP_JAR is killed."
}

restart(){
	stop
	start
}

echo "APP_HOME:$SHELL_FOLDER"
case $1 in
	"start")
		start
		;;
	"stop")
		stop
		;;
	"restart")
		restart
		;;
	*)
		echo "Usage: app.sh ( commands ... )"
		echo "commands:"
		echo "  start             Start java app"
		echo "  stop              Stop java app"
		echo "  restart           Restart java app"
		;;
esac
