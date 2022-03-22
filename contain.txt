#!/bin/bash
# a.txt is really from get_ip function
# b.txt is cloud dns record results
true >/tmp/c.txt
while read -r subdomain subip; do
	echo "domain: $subdomain"
	echo "ip: $subip"
	while read -r strdomain strip; do
		echo "domain: $strdomain"
		echo "ip: $strip"
		if [ "$subdomain" = "$strdomain" ]; then
			if grep -q "$subip" <<<"$strip"; then
				echo "It's there"
			else
				echo "It's not there, So need Print really ip"
				echo "$subdomain $subip" >>/tmp/c.txt
			fi
		fi
	done </tmp/b.txt
done </tmp/a.txt

awk 'BEGIN{while (a++<50) s=s "-"; print s,"request finished , keep checking the /tmp/c.txt",s}'
if [ -s /tmp/c.txt ]; then
	echo "will warning"
	cat /tmp/c.txt
else
	echo "no warning"
fi

string='hellofoo'
case "$string" in
*foo*)
	echo "yes, foo is in $string"
	;;
esac

[[ $string == *foo* ]] && echo "It's there" || echo "Couldn't find"

: <<EOF
https://stackoverflow.com/questions/229551/how-to-check-if-a-string-contains-a-substring-in-bash
if grep -q foo <<<"$strdomain"; then
    echo "It's there"
fi

cat  /tmp/a.txt
www.baidu.com 14.215.177.39,14.215.177.38
www.sohu.com 119.96.200.204

/tmp/b.txt
www.baidu.com 14.215.177.39,14.215.177.38,14.215.177.37
www.sohu.com 119.96.200.204

contain

EOF
