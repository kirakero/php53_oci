#!/bin/bash

# originally from http://www.synet.sk/php/en/190-compiling-PHP5-3-3-under-CentOS-5-with-oracle-instantclient

############################################
# PREPARE SOURCES - all should be copied into /usr/local/src/ with extension [gz|tgz]
# HOWTO:
#		http://www.php.net/manual/en/oci8.installation.php
#		http://ubuntuforums.org/archive/index.php/t-92528.html
#		http://download.oracle.com/docs/cd/B19306_01/server.102/b14357/ape.htm
############################################
#
# IMPORTANT - Dont use instantclient 11g version!
# It has installation compatability issues with OpenLDAP! (redeclared headers)
#
# Install instantclient 10.2.0.5, download instantclient+sqlplus+sdk for linux32 x86 from:
# http://www.oracle.com/technetwork/topics/linuxsoft-082809.html
#
# Or download 64bit linux basic client + SDK from:
# http://www.oracle.com/technetwork/topics/linuxx86-64soft-092277.html
# (you may rename filenames apropriately to work with this shell script)
#
# must have in the same directory as this script:
# instantclient-basic-linux32-10.2.0.5.0.zip
# instantclient-sdk-linux32-10.2.0.5.0.zip
# oci8-1.4.3.tgz

# temporary directory to collect compilation output
TEMP="temp"
#rm -r $TEMP >& /dev/null
mkdir $TEMP >& /dev/null
chmod -R 644 $TEMP

# log filename
STAMP=`date +%Y-%m-%d-%H-%M`
LOG="./$TEMP/compilation-$PHP.$STAMP.log"
echo "LOG - Compilation Results" > $LOG

# get current working directory path
CURRENTDIR=/usr/local/src
cd $CURRENTDIR

# first we will need to unzip instant client
ORA_CLIENT="basic-10.2.0.5.0-linux-x64.zip"
ORA_CLIENT_SDK="sdk-10.2.0.5.0-linux-x64.zip"
ORA_CLIENT_DIR=/usr/local/oracle/

# remove previous directory
rm -r $ORA_CLIENT_DIR >& /dev/null

# create directory and unzip instant client
mkdir $ORA_CLIENT_DIR
pwd
echo $ORA_CLIENT $ORA_CLIENT_DIR
cp $ORA_CLIENT $ORA_CLIENT_DIR
cp $ORA_CLIENT_SDK $ORA_CLIENT_DIR
cd $ORA_CLIENT_DIR
unzip -o $ORA_CLIENT
unzip -o $ORA_CLIENT_SDK
rm $ORA_CLIENT
rm $ORA_CLIENT_SDK

# create symlink:
SUBDIRDIR=`ls`
cd $SUBDIRDIR
echo "subdir"
ls -l
cp libclntsh.so.10.1 libclntsh.so
cp libocci.so.10.1 libocci.so

# return to current working directory
cd $CURRENTDIR

##################################################################

# now we will compile oci8 1.4.3
EXTENSION="oci8-1.4.3"
# untarred directory name
EXTENSIONDIR="$CURRENTDIR/$EXTENSION"

# temporary directory to collect compilation output
TEMP="temp"
#rm -r $TEMP >& /dev/null
mkdir $TEMP >& /dev/null
chmod -R 644 $TEMP

# log filename
STAMP=`date +%Y-%m-%d-%H-%M`
LOG="./$TEMP/compilation-$EXTENSION.$STAMP.log"
OPTIONS="./$TEMP/config-options-$EXTENSION.log"
echo "LOG - Compilation Results" > $LOG

echo "=========================" | tee -a $LOG
echo "Defining resources... done." | tee -a $LOG
echo "=========================" | tee -a $LOG

#############################################
# clean up previosly compiled files
#############################################

# if there has ben previously PHP compilation, we should clean up previously compiled files:
if [ -d "$EXTENSIONDIR" ]
then
	echo "=========================" | tee -a $LOG
	echo "Cleaning up previous compilation.." | tee -a $LOG
	echo "=========================" | tee -a $LOG
	cd $EXTENSIONDIR
	make clean > ./.$LOG
	cd ..
fi

#############################################
# Untar sources
#############################################

echo "=========================" | tee -a $LOG
echo "Untaring sources.." | tee -a $LOG
echo "=========================" | tee -a $LOG

ls -l $CURRENTDIR
echo $EXTENSIONDIR
rm -r $EXTENSIONDIR
tar -zxvf $CURRENTDIR/$EXTENSION.tgz

############################################
# COMPILE
############################################

cd $EXTENSIONDIR

ls -l /usr/local/oracle/instantclient_10_2/
stat /usr/local/oracle/instantclient_10_2/libclntsh.so

phpize
# If you cannot run phpize, install:
# yum install php-devel

echo "$EXTENSION - running config.." >> ./.$LOG
./configure --with-oci8=shared,instantclient,${ORA_CLIENT_DIR}instantclient_10_2 >> ./.$LOG

echo "$EXTENSION - running make.." >> ./.$LOG
make >> ./.$LOG

#echo "$EXTENSION - running make test.." >> ./.$LOG
#make test >> ./.$LOG

echo "$EXTENSION - running make install.." >> ./.$LOG
make install >> ./.$LOG

cd ..

echo "Completed compilation of $EXTENSION in $EXTENSIONDIR. Check logs in [$LOG]"

# ADD extension into /etc/php/php.ini:
# extension=oci8.so
