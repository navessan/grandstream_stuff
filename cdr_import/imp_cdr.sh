#!/bin/bash

SRC=/home/grandstream/cdr
LOG=cdr_import.log

for D in `ls $SRC`
do
    FILE=$SRC/$D
    if [ -f $FILE ]; then
       echo "File $FILE exists."
	php csv2my.php $FILE imp_cdr >> $LOG
    else
       echo "File $FILE does not exist."
fi
done

