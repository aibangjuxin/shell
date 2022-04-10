#!/bin/bash
process=5
tmp_fifofile=/tmp/$$.fifo

mkfifo $tmp_fifofile
exec 9<>$tmp_fifofile
rm $tmp_fifofile
for i in $(seq $process); do
	echo >&9
done

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
		echo "############" # 确实这种取不到值的情况 ,所以其实对于我们来说,直接忽略这个问题? echo"" > /dev/null
	fi
	# display ip
	echo "$ip_address"
}

function get_ipaddr_simple {
	local hostname=$1
	local query_type=A
	ip_address=""
	ip_address="$(host -t ${query_type} "${hostname}" | awk '/has.*address/{print $NF}' | sort -rn | awk BEGIN{RS=EOF}'{gsub(/\n/," ");print}')"
	echo "$ip_address"
}

function get_ip {
    local hostname=$1
	ip_address=""
	ip_address="$(dig +short +noall +answer -t A "${hostname}" |awk '/^[0-9]/'|sort -rn|awk BEGIN{RS=EOF}'{gsub(/\n/," ");print}')"
	echo "$ip_address"
}

for i in $(seq 800); do cat $domain_ip; done >$domain_loop
#for i in {1..5}; do cat /tmp/a.txt; done > $domain_loop

true >$collect_ip
start=$(date +%s)

IFS=' '
while read -r domain_array; do
	read -u 9
	{
		#echo "${domain_array}" "$(get_ipaddr "${domain_array}")" >>$collect_ip
		echo "${domain_array}" "$(get_ipaddr_simple "${domain_array}")" >>$collect_ip
		#echo "${domain_array}" "$(get_ip "${domain_array}")" >>$collect_ip
		echo >&9
	} &
done <$domain_loop

wait
if [ $? -eq 0 ]; then
	echo "generate record successfully"
fi
exec 9>&-

end=$(date +%s)

echo "TIME:$(expr "$end" - "$start")"
echo "hello world "


#cat < $collect_ip
awk 'BEGIN{while (a++<50) s=s "-"; print s,"splite line",s}'
cat < $collect_ip|sort|uniq|awk '{x=$1;$1="";S[x]=$0" "S[x]} END {for (a in S) print a, S[a]}'|sort -k1  > /tmp/c.test
cat < $collect_ip|sort|uniq|awk '{x=$1;$1="";S[x]=$0" "S[x]} END {for (a in S) print a, S[a]}'|sort -k1|sed 's/ /|/'  > /tmp/d.test

awk 'BEGIN{while (a++<50) s=s "-"; print s,"splite line checking the format file",s}'
cat /tmp/d.test

function domain_format {
IFS="|"
while read -r domain ip; do 
      echo -n "$domain"
      for i in $ip;do 
      echo "$i"|tr -s " " "\n"|sort|uniq|tr -s "\n" " "
      done
      echo "" 
done < /tmp/d.test
}

domain_format > /tmp/f.test
awk 'BEGIN{while (a++<50) s=s "-"; print s,"cat f.test",s}'
cat /tmp/f.test



: << EOF
cat /tmp/b.txt|sort|uniq
www.baidu.com 14.215.177.39 14.215.177.38
www.gitee.com 180.97.125.228
www.gitee.com 180.97.125.227
www.sina.com.cn 124.116.156.30 124.116.156.28 124.116.156.27 118.182.230.187 61.159.95.125 61.159.95.124 61.159.95.123
www.sohu.com 119.96.200.204
www.toutiao.com 219.144.108.231 219.144.108.230 219.144.108.229 219.144.108.228 219.144.108.227 219.144.108.226 219.144.108.225 219.144.108.224 113.137.56.236 113.137.56.187 113.137.54.231 113.137.54.230 113.137.54.229 113.137.54.226 113.137.54.195 113.137.54.192
www.toutiao.com 219.144.108.231 219.144.108.230 219.144.108.229 219.144.108.228 219.144.108.227 219.144.108.226 219.144.108.225 219.144.108.224 113.137.56.236 113.137.56.189 113.137.54.227 113.137.54.226 113.137.54.225 113.137.54.224 113.137.54.193 113.137.54.192
www.toutiao.com 219.144.108.231 219.144.108.230 219.144.108.229 219.144.108.228 219.144.108.227 219.144.108.226 219.144.108.225 219.144.108.224 113.137.56.251 113.137.56.250 113.137.54.228 113.137.54.227 113.137.54.226 113.137.54.225 113.137.54.195 113.137.54.194
www.toutiao.com 219.144.108.231 219.144.108.230 219.144.108.229 219.144.108.228 219.144.108.227 219.144.108.226 219.144.108.225 219.144.108.224 113.137.56.252 113.137.56.186 113.137.54.229 113.137.54.228 113.137.54.227 113.137.54.224 113.137.54.196 113.137.54.193

cat /tmp/b.txt|sort|uniq|awk '{x=$1;$1="";S[x]=$0" "S[x]} END {for (a in S) print a, S[a]}'|sort -k1

10 800
./enhance-get-addr.sh  138.82s user 136.10s system 564% cpu 48.676 total
5 800
./enhance-get-addr.sh  122.15s user 118.08s system 363% cpu 1:06.17 total
EOF