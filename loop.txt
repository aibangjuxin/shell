#!/bin/bash
FILENAME="$1"
TIMEFILE="/tmp/loop.txt" > $TIMEFILE
SCRIPT=$(basename $0)

function usage(){
echo "USAGE: $0 filename"
  echo "Examples:"
  echo "  $0 loop filename"
exit 1
}

function while_read_bottm(){
while read LINE
do
echo $LINE
done < $FILENAME
}

function while_read_cat_line(){
cat $FILENAME | while read LINE
do
echo $LINE
done
}

function for_in_file(){
for i in  `cat $FILENAME`
do
echo $i
done
}

if [ $# -lt 1 ] ; then
usage
fi
echo -e " \n time the script \n"
echo -e "method 1:"
echo -e "function while_read_bottm"
time while_read_bottm >> $TIMEFILE
echo -e "\n"

echo -e "method 2:"
echo -e "function while_read_cat_line"
time while_read_cat_line >> $TIMEFILE

echo -e "\n"
echo -e "method 3:"
echo -e "function  for_in_file"
time  for_in_file >> $TIMEFILE
