#!/bin/sh
# Third Party Software
# Mongo Backup Scripts – version 1.0
# Copyright © Orange Business Service – 2019 Guillaume CHARRIER - Vaibhav Jain
# Mongo Backup Scripts is distributed under the terms and conditions of the MIT license (http://spdx.org/licenses/MIT)
# You may download the source code on the following website https://github.com/
###################################################################################################################
# MongoDB backup script : This script uses mongodump utility to take backup of a standalone MongoDB database server
#
# Author(s)
#           : Vaibhav Jain
#           Guillaume CHARRIER
#
# First full backup(snapshot) and subsequently incremental backup of ES on standalone server
#
#  Input parameters :
#
#       MONGOBIN_PATH           : MongoDB Bin directory path
#       MONGO_BKP_DIR           : Location of MongoDB database backup directory
#       MONGO_PORT=27017        : Port no. on which MongoDB is running
#       MONGO_USER_BKP          : Backup user
#       MONGO_PASSWORD_BKP      : Password
#       MONGO_RETENTION_DAYS_BKP: number of days to keep backups
#
####################################################################################################################

#set -x

# input parameters:
${MONGOBIN_PATH+"false"} && echo "MONGOBIN_PATH is unset" && exit 1
${MONGO_BKP_DIR+"false"} && echo "MONGO_BKP_DIR is unset" && exit 1
${MONGO_PORT+"false"} && echo "MONGO_PORT is unset" && exit 1
${MONGO_USER_BKP+"false"} && echo "MONGO_USER_BKP is unset" && exit 1
${MONGO_PASSWORD_BKP+"false"} && echo "MONGO_PASSWORD_BKP is unset" && exit 1
${MONGO_RETENTION_DAYS_BKP+"false"} && echo "MONGO_RETENTION_DAYS_BKP is unset" && exit 1

# derived parameters

TIMESTAMP=`date +%F-%H%M`
MONGO_BKP_NAME_PRFIX="mongobkp_"
MONGO_BKP_NAME="$MONGO_BKP_NAME_PRFIX$TIMESTAMP"        #Name current backup directory
MONGO_BKP_DEST=$MONGO_BKP_DIR/$MONGO_BKP_NAME           #full path of current backup directory
MONGO_BKP_LOG=$MONGO_BKP_DEST/$MONGO_BKP_NAME.log       #Log for the current backup activity

echo "MONGOBIN_PATH="$MONGOBIN_PATH
echo "MONGO_BKP_DIR="$MONGO_BKP_DIR
echo "MONGO_PORT="$MONGO_PORT
echo "MONGO_USER="$MONGO_USER
echo "MONGO_RETENTION_DAYS_BKP="$MONGO_RETENTION_DAYS_BKP
echo "MONGO_BKP_NAME="$MONGO_BKP_NAME
echo "MONGO_BKP_DEST="$MONGO_BKP_DEST
mkdir -p $MONGO_BKP_DEST

# Backup procedure

ps -ef | grep mongod | grep -v "grep mongod" > /dev/null
if [ $? -eq 0 ];then
  echo "[`date`] : MongoDB instance is running ..." >> "${MONGO_BKP_LOG}"
  echo "[`date`] : running MongoDB backup ..." >> "${MONGO_BKP_LOG}"
  echo " " >>  "${MONGO_BKP_LOG}"

  #Backup all databases using mongodump

  ${MONGOBIN_PATH}/mongodump --port $MONGO_PORT --username $MONGO_USER_BKP --password $MONGO_PASSWORD_BKP --gzip --oplog --out $MONGO_BKP_DEST >>  "${MONGO_BKP_LOG}" 2>&1

  ret=$?
  if [ $ret -eq 0 ];then
        echo "[`date`] : MongoDB backup completed OK." >> "${MONGO_BKP_LOG}"
        echo " " >>  "${MONGO_BKP_LOG}"
        echo "[`date`] : Purging backups older than $MONGO_RETENTION_DAYS_BKP days" >> "${MONGO_BKP_LOG}"
        find ${MONGO_BKP_DIR} -mtime +${MONGO_RETENTION_DAYS_BKP} -type d -name $MONGO_BKP_NAME_PRFIX"*" -print -exec rm -rf {} \; 2>&1  >>  "${MONGO_BKP_LOG}"
        echo "End" >>  "${MONGO_BKP_LOG}"
        exit 0
  else
        echo "[`date`] : MongoDB backup failed." >> "${MONGO_BKP_LOG}"
        echo "End" >>  "${MONGO_BKP_LOG}"
        exit 1
  fi

else
  echo "[`date`] : MongoDB database instance is down" >> "${MONGO_BKP_LOG}"
  echo "[`date`] : MongoDB backup failed." >> "${MONGO_BKP_LOG}"
  echo "End" >>  "${MONGO_BKP_LOG}"
  echo "Backup failed"
  exit 1
fi
