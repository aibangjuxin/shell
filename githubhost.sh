
#!/bin/bash
urls="
https://gitee.com
"
echo "$urls"
for url in $urls;do
    count=0
    while [ $count -lt 3 ];do
       STATUS=$(curl -I -m 10 -o /dev/null -s -w %{http_code} $url)

       if [ "$STATUS" -eq 200 ];then
          echo "$url  OK"
          #sed -i "" "/GitHub/d" /etc/hosts
          sed -i "" '28,$d' /etc/hosts
          curl https://gitee.com/ineo6/hosts/raw/master/hosts >> /etc/hosts
          break 1
       fi
       count=$(($count+1))
    done
    if [ $count -eq 3 ];then
       echo "$url Error"
    fi
done

#sed -i "" "/GitHub/d" /etc/hosts
#curl https://gitee.com/ineo6/hosts/raw/master/hosts >> /etc/hosts

