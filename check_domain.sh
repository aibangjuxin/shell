#!/bin/bash
if [ "$1" == "-h" ]; then
    cat <<EOF
*****************************************************************
* This is my study script
* Power by Lex. Let's go! and be happy!
* version 1.0
  echo "Examples:"
  only ./${0##*/}
*****************************************************************
EOF
exit 0
fi

SCRIPT_NAME="${0##*/}"
info() {
    echo "${SCRIPT_NAME}: ${1}"
}
warn() {
    info "[WARNING]: ${1}" >&2
}

fatal() {
    warn "ERROR: ${1}"
    exit 2
}
# define domain list
finish() {
    # shellcheck disable=SC2181
    if [ $? -ne 0 ]; then
        echo "ERROR: failed your command."
    fi
}

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
    host -t ${query_type} "${hostname}" ${dnsserver} &>/dev/null
    if [ "$?" -eq "0" ]; then
        # get ip address
        ip_address="$(host -t ${query_type} "${hostname}" ${dnsserver} | awk '/has.*address/{print $NF; exit}')"
    else
        echo "############"
    fi
    # display ip
    echo "$ip_address"
}

true >$collect_ip
#cat /home/lex/dns/a.txt| while IFS=" " read -r line;do domain_array+=("$line");done
# The next ok and for loop
#domain_array=($(awk '{print$1}' <$domain_ip))
# If the output should be a single element: SC2207 the next ok .but slow
#domain_array=("$(awk '{print$1}' <$domain_ip)")
# The next ok but not loop
#IFS=" " read -r -a domain_array <<< "$(cat $domain_ip|awk '{print$1}')"
#echo "${domain_array[@]}"
awk 'BEGIN{while (a++<50) s=s "-"; print s,"testing output only one",s}'
IFS=' ' read -r -a domain_array <<< "$(cat < $domain_ip|awk '{print$1}')"
echo "${domain_array[@]}"
awk 'BEGIN{while (a++<50) s=s "-"; print s,"testing output finished",s}'

awk 'BEGIN{while (a++<50) s=s "-"; print s,"testing read from file",s}'
IFS=' '
while read -r domain_array ip_array;do
    echo "domain_array is ${domain_array}"
    get_ipaddr "${domain_array}"
    echo "${domain_array}" "$(get_ipaddr "${domain_array[$i]}")" >>$collect_ip
    echo "ip_array is ${ip_array}"
done < $domain_ip
awk 'BEGIN{while (a++<50) s=s "-"; print s,"get_ipaddr and collect ip finished",s}'
cat $collect_ip

# the next old ,but's ok
#domain_array=($(awk '{print$1}' <$domain_ip))#
#for ((i = 0; i < ${#domain_array[@]}; i++)); do
#	echo -e "\033[31m ${domain_array[$i]} \033[0m"
#	#echo ${domain_array[$i]}
#	get_ipaddr "${domain_array[$i]}"
#	echo "${domain_array[$i]}" "$(get_ipaddr "${domain_array[$i]}")" >>$collect_ip
#done

awk 'BEGIN{while (a++<50) s=s "-"; print s,"分割线",s}'
echo "now begin compare file"
function checkfilesume() {
    local_file_sum=$(md5sum $domain_ip | cut -d" " -f1)
    gener_file_sum=$(md5sum $collect_ip | cut -d" " -f1)
    if [ "$local_file_sum" == "$gener_file_sum" ]; then
        echo "checksum success"
    else
        echo "checksum failure"
    fi
}
#checkfilesume
awk 'BEGIN{while (a++<50) s=s "-"; print s,"diff file",s}'
true >/tmp/c.txt
diff /tmp/a.txt /tmp/b.txt
#sdiff /tmp/a.txt /tmp/b.txt
#sdiff /tmp/a.txt /tmp/b.txt|grep "|"
if [ $? -eq 0 ]; then
    echo "compare record successfully"
    echo "the next will exit this script"
    exit
else
    echo "Because The result different . next I will testing request domain and ip"
    awk 'BEGIN{while (a++<50) s=s "-"; print s,"will generate c.txt",s}'
    #sdiff /tmp/a.txt /tmp/b.txt|grep "|" > /tmp/c.txt
    #cat /tmp/c.txt|while IFS=" " read -r line;do domain_array+=("$line");done
    # 对旧的记录进行再次检查,看是否能够访问,所以过滤的 <
    #diff /tmp/a.txt /tmp/b.txt|grep "<"|awk '{print$2}' > /tmp/c.txt
    diff /tmp/a.txt /tmp/b.txt | grep "<" | awk '{for(i=2;i<=NF;i++){printf "%s ", $i}; printf "\n"}' >/tmp/c.txt
    diff_ip=/tmp/c.txt

    if [ -s "$diff_ip" ]; then
        echo " the diff ip"
        awk 'BEGIN{while (a++<50) s=s "-"; print s,"testing request domian ip ",s}'
        IFS=' '
        while read -r domain ip; do
            echo "domain: $domain"
            echo "ip: $ip"
            echo "-----------------------------"
            echo "$domain $ip"
            #stat=$(/usr/bin/curl -o /dev/null -s -w %{http_code} https://$ip -H "Host:$domain" -k)
            stat=$(/usr/bin/curl -o /dev/null -s -w %'{http_code}' https://"$ip" -H "Host:$domain" -k)
            echo "$stat"
            if [ "$stat" -eq 200 ]; then
                echo "The metadata is available. we will house keep /tmp/c.txt"
                sed -i.bak "/$domain/d" /tmp/c.txt
            else
                echo "The metadata is unavailable. keep file /tmp/c.txt"
                echo "So next we need keep Checking The /tmp/c.txt"
            fi
        done <$diff_ip
    else
        echo "no diff ip all of ok .Don't worry . GoodBye"
    fi
fi
awk 'BEGIN{while (a++<50) s=s "-"; print s,"request finished , keep checking the /tmp/c.txt",s}'
if [ -s /tmp/c.txt ]; then
    echo "will warning"
else
    echo "no warning"
fi

: <<EOF
#
#cat /tmp/a.txt
www.baidu.com 14.215.177.39
www.sohu.com 119.96.200.204

diff /tmp/a.txt /tmp/b.txt
1c1
< www.baidu.com 14.215.177.39
---
> www.baidu.com 14.215.177.38 这个是收集到的IP地址


➜  shell diff /tmp/a.txt /tmp/c.txt
➜  shell echo $?
0

➜  shell cat /tmp/c.txt
www.baidu.com 14.215.177.39,14.215.177.38

EOF
