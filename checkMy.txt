#!/usr/local/bin/bash
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
         echo "   [-q] [-s seconds] [-w limits] [-c limits]"
         echo "Source:"
         ;;
    *) esac
done

if [ ! "$e" ]; then
    echo "please enter env and api region" >&2
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
    echo "please enter your command" >&2
    exit 1
fi

function update()
{
echo "update"
echo "need a new zone name"
echo "need a new A record"
}

awk 'BEGIN{while (a++<50) s=s "-"; print s,"splite line",s}'
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

awk 'BEGIN{while (a++<50) s=s "-"; print s,"splite line",s}'
file=/Users/lex/Downloads/git/shell/checkMy.sh
echo ... result is "$(wc -l < $file)" lines long.


#hostlist=($(cat /Users/lex/shell/ip.txt)) 这种写法有告警.
#mapfile myarr < /Users/lex/shell/ip.txt 这个在bash 5.0没有问题
#echo "${myarr[@]}"
#使用"-t"选项，在每次读取一行后就去掉该行的换行符
mapfile -d " " -t myarr < /Users/lex/shell/ip.txt
echo "${myarr[@]}"
echo "+++++++这个是乱的+++++++"
echo " other如果按照整行读入不能将每一个元素作为循环对象"
#mapfile -d " " -t hostlist < /Users/lex/shell/ip.txt
IFS=" " read -r -a hostlist <<< "$(cat /Users/lex/shell/ip.txt|tr -s '\n' " ")"
for (( i=0;i<${#hostlist[@]}; i+=4 ));do
    ip=${hostlist[i]}
    username=${hostlist[i+1]}
    password=${hostlist[i+2]}
    port=${hostlist[i+3]}
    echo "${ip}" "${port}"
    echo "${username}" "${password}"
    done

awk 'BEGIN{while (a++<50) s=s "-"; print s,"splite line",s}'
hostlist=($(cat /Users/lex/shell/ip.txt))
for (( i=0;i<${#hostlist[@]}; i+=4 ));do
    ip=${hostlist[i]}
    username=${hostlist[i+1]}
    password=${hostlist[i+2]}
    port=${hostlist[i+3]}
    echo "${ip}" "${port}" "${username}"
    echo "${username}" "${password}"
    done


:<<EOF

./checkMy.sh -e pdev-hk -c update
-------------------------------------------------- 分割线 --------------------------------------------------

for i in ${!array[*]};do
    IFS=',' read -ra fn <<< "${array[$i]}"
    fn_name=${fn[*]}
    echo "The all of filename is $fn_name"
done

you input env_arr parameter is pdev-hk
pdev-hk
update
china-010115-wwwsp08-dev
update
need a new zone name
need a new A record

space_arr=(dev sit uat)
region_arr=(asia cn hk)

while getopts ":v:s:r:j:" o; do
  case $o in
    v)  pmu_version=${OPTARG};;
    s)  space=${OPTARG}
        [[ " ${space_arr[*]} " == *" $space "* ]] || usage
        ;;
    r)  region=${OPTARG}
        [[ " ${region_arr[*]} " == *" $region "* ]] || usage
        ;;
    j)  job_id=${OPTARG};;
    *)  usage;;
  esac
done

if [ -z $pmu_version ] || [ -z $space ] || [ -z $region ] || [ -z $job_id ]; then
  usage
fi

ash-5.0$ mapfile myarr < ip.txt
bash-5.0$ echo ${myarr[@]}
10.211.55.4 root aibang 22 10.211.55.5 root aibang 23 10.211.55.6 root aibang 24 10.211.55.7 root aibang 25



Problematic code:
https://github.com/koalaman/shellcheck/wiki/SC2207

EOF
