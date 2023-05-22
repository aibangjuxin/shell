#!/usr/local/bin/bash
declare -A env_info
env_info=(
	["lex-hk"]="project=lex-1111151-lex-dev cluster=lex-hk-cluster-421b39 region=europe-west2 https_proxy=10.98.21.119:3128 private_network=aibang-1111151-lexgw-dev-cinterna"
)

environment=""

usage() {
	echo "使用方法: $0 -e 环境"
	echo "可用的环境选项:"
	for key in "${!env_info[@]}"; do
		echo "  $key"
	done
}

# 判断第一个参数是否为 -e
if [[ $# -eq 0 || "$1" != "-e" ]]; then
	usage
	exit 1
fi

#if [[ "$1" == "--help" ]]; then
#    usage
#    exit 0
#fi

while getopts "e:h" opt; do
	case ${opt} in
	e)
		if [[ -z "${OPTARG}" ]]; then
			echo "环境选项为空"
			usage
			exit 1
		fi
		environment=${OPTARG}
		;;
	h)
		usage
		exit 0
		;;
	*)
		usage
		exit 1
		;;
	esac
done

if [[ -z "${environment}" ]]; then
	echo "缺少环境选项"
	usage
	exit 1
fi

if [[ -z "${env_info[$environment]}" ]]; then
	echo "无效的环境: $environment"
	usage
	exit 1
fi

env_vars="${env_info[$environment]}"
IFS=" " read -ra var_array <<<"$env_vars"
for var in "${var_array[@]}"; do
	IFS="=" read -r key value <<<"$var"
	export "$key=$value"
done

echo "Environment: $environment"
echo "Project: $project"
echo "Region: $region"
echo "Cluster: $cluster"
echo "https_proxy: $https_proxy"
echo "private_network: $private_network"

function get_cluster_info() {
	gcloud container clusters describe ${cluster} --region ${region} --format='flattened(currentNodeVersion,currentMasterVersion,name,nodePools[].name)'
}

function get_node_pools() {
	gcloud container node-pools list --cluster ${cluster} --zone ${region} --project ${project} --format="csv[no-heading](NAME)"
}
