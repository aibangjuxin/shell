#!/bin/bash
true > /tmp/gcr_report.txt
while read LINE
do
    echo "$LINE" >> /tmp/gcr_report.txt
    fully_qualified_digest=$(gcloud container images describe "$LINE" --format='value(image_summary.fully_qualified_digest)')
    gcloud beta container images describe "$fully_qualified_digest" --show-package-vulnerability --format=json|jq '.discovery_summary.discovery[0].discovery,.discovery_summary.discovery[0].updateTime' >> /tmp/gcr_report.txt
done < /tmp/images_success_list.txt

#!/usr/bin/env bash

while getopts :d:g:s:p:r: opt;do
    case $opt in
        d)
        vulnDispensation=$OPTARG
        ;;
        g)
        artifactGav=$OPTARG
        ;;
        s)
        severity=$OPTARG
        ;;
        p)
        projectName=$OPTARG
        ;;
        r)
        registry=$OPTARG
        ;;
        *)
        echo "error input"
        exit 1
    esac
done

if [ -n "${artifactGav}" ];then
    artifactGav_arr=(${artifactGav//:/ })
    group=${artifactGav_arr[0]//.//}
    name=${artifactGav_arr[1]}
    version=${artifactGav_arr[2]}
    imageFullPath="${registry}/${projectName}/${name}:${version}"

    count=1
    while [[ ${count} -le 3 ]]
    do
        cve_api_status=`curl -ki https://cybervault.systems.uk.hsbc/api/v1/cve/ -w %{http_code} -o /dev/null`
        if [[ "${cve_api_status}" -eq "200" ]]; then
            break
        else
            count=$(( $count + 1 ))
            sleep 30s
        fi
    done
    if [[ "${count}" == "4" ]]
    then
        exit 2
    fi

    cybervault-cve-report -l DEBUG --max-severity ${severity} --gcp-project ${projectName} --gcr-image ${imageFullPath} -r ./gcrScanResultCyberVaultReport.json
else
    echo "ERROR: artifactGav is null"
    exit
fi

get_vulnerabilities_summary.sh
#!/usr/bin/env bash
artifactGav=$1
version=''
group=''
name=''


if [ -n "$artifactGav" ];then
    artifactGav_arr=(${artifactGav//:/ })
    group=${artifactGav_arr[0]//.//}
    name=${artifactGav_arr[1]}
    version=${artifactGav_arr[2]}
fi

project=`gcloud config list|grep project|awk '{print $3}'`
gcr_docker="gcr.io/$project"
#docker rmi ${gcr_docker}/${name}:${version}
gcloud auth configure-docker --quiet
gcloud alpha container images describe ${gcr_docker}/${group}/${name}:${version} --show-package-vulnerability > vulnerabilitiesScanResultRawData.txt
linenum=`sed -n '/analysisStatus/=' vulnerabilitiesScanResultRawData.txt`
content="$(head -${linenum} vulnerabilitiesScanResultRawData.txt)"
analysisStatus=${content##*:}
echo $analysisStatus

#!/bin/bash
# Please run this script by your own AD service account(make sure it is in devops-priv group) not stage3 image builder SA
# This scripte depend docker .so you should running it at mgmt instance by root user.
# The script will do:
# get gke pod images_list and repull all of images and rmi local 

env_arr=(pdev-uk dev-be dev-uk sit-uk uat-uk ppd-uk ppt-uk prd-uk pdev-hk dev-hk sit-hk uat-hk ppd-hk prd-hk)
function usage() {
  echo "Usage: $0 [-e <dev-be|dev-uk|sit-uk|uat-uk|ppd-uk|ppt-uk|prd-uk|pdev-hk|dev-hk|sit-hk|uat-hk|ppd-hk|prd-hk>]" 1>&2
  echo "get gke pod images_list and repull all of images and rmi local."
  echo
  echo "  -e       env and apiRegion                                              required"
  echo
  echo "Examples:"
  echo "  $0 -e pdev-uk"
  exit 1
}

while getopts ":e:" o; do
  case $o in
    e)  e=${OPTARG}
    [[ " ${env_arr[*]} " == *" $e "* ]] || usage
    ;;
    *)  usage;;
  esac
done
if [ ! "$e" ]; then 
    echo "please enter env and api region"
    exit 1
fi


finish() {
    # shellcheck disable=SC2181
    if [ $? -ne 0 ]; then
        echo "ERROR: failed your command."
    fi
} 
echo "check docker process whether running"
ps aux|grep docker|grep containerd
pgrep docker
finish
gcloud auth configure-docker --quiet

source ./env/"$e"-params.sh
# get all of pods images 
kubectl get pods -A -o jsonpath="{..image}" |tr -s '[[:space:]]' '\n' |grep "$project"|sort|uniq > /tmp/"$e"_images_list.txt
unset https_proxy
## need prepare /tmp/images_list.txt file
if [ -s /tmp/"$e"_images_list.txt ];then
  echo "The /tmp/"$e"_images_list.txt prepare ok"
  else
  echo "Please prepare you image list"
  exit 1
fi

## now get current gcr report and found the continuousAnalysis INACTIVE
function gcr_scan {
local read_images_list=$1
local generate_report=$2
true > "${generate_report}"
while read LINE
do
    echo "$LINE" >> "${generate_report}"
    fully_qualified_digest=$(gcloud container images describe "$LINE" --format='value(image_summary.fully_qualified_digest)')
    gcloud beta container images describe "$fully_qualified_digest" --show-package-vulnerability --format=json|jq '.discovery_summary.discovery[0].discovery,.discovery_summary.discovery[0].updateTime' >> "${generate_report}"
done < "${read_images_list}"
}

gcr_scan /tmp/"$e"_images_list.txt /tmp/"$e"_gcr_report_old.txt
# if the continuousAnalysis is not ACTIVE or INACTIVE

function get_number_images {
image_num=$(docker images -a|wc -l)
    if [ "$image_num" -gt 20 ];then
	echo "need delete"
	docker rmi $(docker images -a -q)
	else
	echo "go on"
    fi
}

images_failure_list=/tmp/images_failure_list.txt
images_success_list=/tmp/images_success_list.txt
true > $images_failure_list
true > $images_success_list
while read -r pulllist
do
    echo "docker pull $pulllist"
    docker pull "$pulllist"
    if [ "$?" -eq "0" ]; then
        echo "$pulllist" >> $images_success_list
	get_number_images
	else
	echo "$pulllist" >>  $images_failure_list
    fi
done  < /tmp/"$e"_images_list.txt


if [ -s $images_failure_list ];then
  echo "Please checking The failure list"
  else
  echo "docker pull finished"
fi

gcr_scan /tmp/images_success_list.txt /tmp/"$e"_gcr_report.txt