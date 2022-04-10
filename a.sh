#!/bin/bash
# define domain list
domain_ip=/tmp/a.txt
domain_loop=/tmp/domain_loop.txt
collect_ip=/tmp/b.txt
diff_ip=/tmp/c.txt
# Specify DNS server
dnsserver="119.29.29.29"
# function to get IP address
function get_ipaddr {
	local hostname=$1
	local query_type=A
	ip_address=""
	# use host command for DNS lookup operations
	host -t ${query_type} "${hostname}" ${dnsserver} &>/dev/null
	if [ "$?" -eq "0" ]; then
		# get ip address
		ip_address="$(host -t ${query_type} "${hostname}" | awk '/has.*address/{print $NF}' | sort -rn | awk BEGIN{RS=EOF}'{gsub(/\n/," ");print}')"
	else
		echo "############"
	fi
	# display ip
	echo $ip_address
}

for i in $(seq 20); do cat $domain_ip; done > $domain_loop

true >$collect_ip

domain_array=($(awk '{print$1}' <$domain_loop))
for ((i = 0; i < ${#domain_array[@]}; i++)); do
    {
	echo "${domain_array[$i]}" "$(get_ipaddr "${domain_array[$i]}")" >>$collect_ip
    } &
done
wait
if [ $? -eq 0 ]; then
	echo "generate record successfully"
fi

echo "hello world "


