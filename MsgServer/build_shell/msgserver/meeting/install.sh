#!/bin/sh
CLEAN_FLAG=0
if [ "$1" = "-u" ]; then
CLEAN_FLAG=1
fi

TARGET_PREFIX=/usr/local/dync/msgserver/meeting
TARGET_CONF_PATH=$TARGET_PREFIX/conf
TARGET_BIN_PATH=$TARGET_PREFIX/bin
TARGET_LOG_PATH=$TARGET_PREFIX/log
TARGET_LIB_PATH=$TARGET_PREFIX/lib
SYS_BIN_PATH=/usr/bin
SYS_INIT_PATH=/etc/init.d

if [ "$CLEAN_FLAG" = "0" ]; then
printf "Install program....\r\n"
mkdir -p $TARGET_CONF_PATH
mkdir -p $TARGET_BIN_PATH
mkdir -p $TARGET_LOG_PATH
mkdir -p $TARGET_LIB_PATH
mkdir -p $SYS_BIN_PATH
# exe sh
cp -f meeting.sh $SYS_BIN_PATH/meeting.sh
chmod 755 $SYS_BIN_PATH/meeting.sh

cp -f meeting.conf $TARGET_CONF_PATH/
cp -f bin/MsgServerMeeting $TARGET_BIN_PATH/
printf "Install program ok!\r\n"
else
printf "UnInstall program....\r\n"
connector.sh stop
rm -f $SYS_BIN_PATH/meeting.sh
rm -f $TARGET_CONF_PATH/meeting.conf
rm -f $TARGET_BIN_PATH/MsgServerMeeting
rm -rf $TARGET_PREFIX
printf "UnInstall program ok!\r\n"
fi
