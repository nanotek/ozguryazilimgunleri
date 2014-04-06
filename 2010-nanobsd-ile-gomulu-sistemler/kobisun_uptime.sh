#!/bin/sh
#
#
# kobisun.org uptime script
#
# This script will update the kobisun.org kobisun.uptime file
# 
#

DATA_DIR=/usr/kobisun
FILE_NAME=`hostname`.uptime

if [ ! -d ${DATA_DIR} ]
	then
	mkdir ${DATA_DIR}
fi

uptime > $DATA_DIR/$FILE_NAME
rsync $DATA_DIR/$FILE_NAME root@kobisun.org:/$DATA_DIR/$FILE_NAME

