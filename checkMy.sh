#!/bin/bash
# Fetching the parameters
#
env_arr=(asia-es1 asia-es2 eu-a eu-b pdev-cn prd-cn)
cmd_arr=(update delete adddns)
function usage() {
  echo "Usage: $0 [-e <asia-es1 asia-es2 eu-a eu-b>]" 1>&2
  echo "Create a new zone name and A recored in specified environment."
  echo
  echo "  -e       env and apiRegion                                              required"
  echo
  echo "Examples:"
  echo "  $0 -e asia-es1"
  exit 1
}

if [ "$1" == "-h" ] ; then
cat << EOF
*****************************************************************
* Initializing system, please try later!
* Power by Lex. Let's go! and be happy!
* version 1.0
  echo "Examples:"
  echo "  $0 -e asia-es1 -c update or delete or adddns"
*****************************************************************
EOF
exit 0
fi


while getopts ":e:c:h:" o; do
  case $o in
    e)  e=${OPTARG}
    [[ " ${env_arr[*]} " == *" $e "* ]] || usage
    ;;
    c)  c=${OPTARG}
    [[ " ${cmd_arr[*]} " == *" $c "* ]] || usage
    ;;
    h)  echo "a script to "
         echo "Usage:"
         echo "$0 -h"
         echo "$0 [-H hostname] [-P port] [-u username] [-p password] \\"
         echo "        [-q] [-s seconds] [-w limits] [-c limits]"
         echo "Source:"
         ;;
    *) esac
done

if [ ! "$e" ]; then
    echo "please enter env and api region"
    exit 1
fi

case $e in
    "asia-es1")
     project=china-010115-ddd-dev
     ;;
    "asia-es2")
     project=china-0290910-pp-dev
     ;;
    "eu-a"|"eu-b")
     project=china-0290910-aaa-dev
     ;;
     "prd-cn")  project=china-apichina-prod;;
    *) echo "Error input space and region!"
       exit 1
esac    

if [ ! "$c" ]; then
    echo "please enter your command"
    exit 1
fi

function update()
{
echo "update" 
echo "need a new zone name"
echo "need a new A record"
}

awk 'BEGIN{while (a++<50) s=s "-"; print s,"分割线",s}'
echo "you input env_arr parameter is $e"
echo "$2"

if [ "$4" == "update" ];
then
    echo "update"
    echo $project
    update
fi

if [ "$4" == "delete" ];
then
    echo "delete"
fi






:<<EOF

./checkMy.sh -e pdev-hk -c update
-------------------------------------------------- 分割线 --------------------------------------------------
you input env_arr parameter is pdev-hk
pdev-hk
update
china-010115-cmbsp08-dev
update
need a new zone name
need a new A record


EOF