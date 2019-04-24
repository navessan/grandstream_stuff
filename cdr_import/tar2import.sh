#!/bin/bash

SRC=/home/grandstream/
CDR_PATH=/home/grandstream/cdr
LOG=cdr_import.log
cdr_master=tmp/CDR/11/cdr-csv/Master.tar.gz

echo cleaning old files in $CDR_PATH
rm $CDR_PATH/*

mdate=$(date +"%Y%b%d")
mask=backup_000B82B80104_$mdate\_*.tar

echo mdate=$mdate
echo mask=$mask

#i hope it will be only one backup file
for f in `ls $SRC/$mask`
do
    FILE=$f
    if [ -f $FILE ]; then
	echo "File $FILE exists."
	tar -xvf $FILE $cdr_master
	tar -xvf $cdr_master -C $CDR_PATH
    else
	echo "File $FILE does not exist."
fi
done

my_table=imp_cdr

php clean_table.php $my_table

for D in `ls $CDR_PATH`
do
    FILE=$CDR_PATH/$D
    if [ -f $FILE ]; then
	echo "File $FILE for import."
	php csv2my.php $FILE $my_table >> $LOG
    else
	echo "File $FILE does not exist."
fi
done
