#!/bin/bash
# define domain list
domain_ip=/tmp/a.txt
domain_loop=/tmp/domain_loop.txt
collect_ip=/tmp/b.txt
diff_ip=/tmp/c.txt
# Specify DNS server
dnsserver="119.29.29.29"
# function to get IP address

function get_ipaddr_simple {
	local hostname=$1
	local query_type=A
	ip_address=""
	ip_address="$(host -t ${query_type} "${hostname}" 119.29.29.29| awk '/has.*address/{print $NF}' | sort -rn | awk BEGIN{RS=EOF}'{gsub(/\n/," ");print}')"
	echo "$ip_address"
}

for i in $(seq 20); do cat $domain_ip; done >$domain_loop
#for i in {1..5}; do cat /tmp/a.txt; done > $domain_loop

true >$collect_ip

IFS=' '
while read -r domain_array; do
	{
		#get_ipaddr_simple "${domain_array}" >>$collect_ip
		echo "${domain_array}" "$(get_ipaddr_simple "${domain_array}")" >>$collect_ip
	} &
done <$domain_loop
wait
# 下面也可以但是语法报错
#domain_array=($(awk '{print$1}' <$domain_loop))
#for ((i = 0; i < ${#domain_array[@]}; i++)); do
#    {
#	#echo -e "\033[31m ${domain_array[$i]} \033[0m"
#	echo "${domain_array[$i]}" "$(get_ipaddr "${domain_array[$i]}")" >>$collect_ip
#    } &
#done

if [ $? -eq 0 ]; then
	echo "generate record successfully"
fi

echo "hello world "
