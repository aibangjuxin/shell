function check_metadata_is_available() {
  local count=0
  local flag=$(curl -I -m 10 -o /dev/null -s -w %{http_code} http://www.baidu.com)
  if [ -z $flag ]; then
    while [ $count -lt 3 ]; do
      echo "30 seconds sleep and try again ..."
      sleep 30
      flag=$(curl -I -m 10 -o /dev/null -s -w %{http_code} http://www.baidu.com)
      [ $flag ] && break
      count=$(($count+1))
    done
  fi
  echo "The number of attempts to run check_metadata_is_available function: $count"
  echo "The flag: $flag"
  [ $flag ] && echo "The metadata is available" || echo "The metadata is unavailable"
}
check_metadata_is_available
#curl -s "http://www.baidu.com" -H "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.1 Safari/605.1.15"
