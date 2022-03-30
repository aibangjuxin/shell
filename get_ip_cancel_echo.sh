#!/bin/bash
domain_ip=/tmp/a.txt
collect_ip=/tmp/b.txt
# Specify DNS server
dnsserver="119.29.29.29"
# function to get IP address
function get_ipaddr {
	local hostname=$1
	local query_type=A
	ip_address=""
	# use host command for DNS lookup operations
	#host -t ${query_type} "${hostname}" ${dnsserver} &>/dev/null
	#if [ "$?" -eq "0" ]; then
	# get ip address
	ip_address="$(host -t ${query_type} "${hostname}" | awk '/has.*address/{print $NF}' | sort -rn | awk BEGIN{RS=EOF}'{gsub(/\n/,",");print}')"
	#else
	#    echo "############"
	#fi
	# display ip
	echo "$ip_address"
}
true >$collect_ip
awk 'BEGIN{while (a++<50) s=s "-"; print s,"testing output only one",s}'
IFS=' ' read -r -a domain_array <<<"$(cat <$domain_ip | awk '{print$1}')"
echo "${domain_array[@]}"
awk 'BEGIN{while (a++<50) s=s "-"; print s,"testing output finished",s}'

awk 'BEGIN{while (a++<50) s=s "-"; print s,"testing read from file",s}'
IFS=' '
while read -r domain_array ip_array; do
	#echo "domain_array is ${domain_array}"
	#get_ipaddr "${domain_array}"
	#echo "${domain_array}" "$(get_ipaddr "${domain_array[$i]}")" >>$collect_ip
	echo "${domain_array}" "$(get_ipaddr "${domain_array}")" >>$collect_ip
	#echo "ip_array is ${ip_array}"
done <$domain_ip
awk 'BEGIN{while (a++<50) s=s "-"; print s,"get_ipaddr and collect ip finished",s}'
cat $collect_ip

: <<EOF
wc -l /tmp/a.txt
125 /tmp/a.txt
./get_ip.sh  8.68s user 7.22s system 44% cpu 36.105 total
./get_ip_cancel_echo.sh  4.29s user 3.69s system 44% cpu 17.943 total
./get_ip_cancel_echo.sh  3.04s user 2.80s system 61% cpu 9.529 total
EOF
