#!/bin/bash
 echo -e "\033[32m ---------------------------- \033[0m"
 echo -e "\033[32m       | hello world  |       \033[0m"
 echo -e "\033[32m ---------------------------- \033[0m"
 env_arr=(dev uat prd)
 function usage() {
echo "Usage: $0 [-e <dev uat prd>]" 1>&2
echo "Create a new test in specified environment."
echo " -e env and apiRegion required"
echo " -v target version required"
echo " -n name optional"
echo
echo "Examples:"
echo " $0 -e dev"
exit 1
}
while getopts ":e:v:n:" o; do
  case $o in
  e) e=${OPTARG}
  [[ " ${env_arr[*]} " == *" $e "* ]] || usage
  ;;
  v) version=${OPTARG}
  ;;
  n) name=${OPTARG}
  ;;
  *) usage;;
  esac
done
if [ ! $e ]; then
echo "please enter env and api region"
exit 1
fi



cat << EOF

this is a common echo

EOF


cat << "EOF"
           \
    \
               |    .
           .   |L  /|
       _ . |\ _| \--+._/| .
      / ||\| Y J  )   / |/| ./
     J  |)'( |        ` F`.'/
   -<|  F         __     .-<
     | /       .-'. `.  /-. L___
     J \      <    \  | | O\|.-'
   _J \  .-    \/ O | | \  |F
  '-F  -<_.     \   .-'  `-' L__
 __J  _   _.     >-'  )._.   |-'
 `-|.'   /_.           \_|   F
   /.-   .                _.<
  /'    /.'             .'  `\
   /L  /'   |/      _.-'-\
  /'J       ___.---'\|
    |\  .--' V  | `. `
    |/`. `-.     `._)
       / .-.\
 VK    \ (  `\
        `.\
EOF


## Logger info 1


max_retry=10
wait_time=5s
retry_count=0
while [ $retry_count -lt $max_retry ];
do
  ((retry_count++))
  iface=hahah
  if [[ -n $iface ]];
  then
    echo "eth1 exist."
    break
  fi
  echo "WARNING: Unable to find the expected eth1 interface."
  echo "Try $wait_time times"

  sleep $wait_time
done

