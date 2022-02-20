#!/usr/local/bin/bash
#readarray -t删除文本结尾的换行符
#两个<之间一定要有一个空格。第2个<要与小括号紧挨着
declare -a lines
readarray -t lines < <(cat /Users/lex/shell/ip.txt|tr -s '\n' " ")
for line in "${lines[@]}"; do
	echo "${line}"
done


:<<EOF
declare -a hostlist
readarray -t hostlist < <(cat /Users/lex/shell/ip.txt)
#hostlist=($(cat /Users/lex/shell/ip.txt))
for (( i=0;i<${#hostlist[@]}; i+=4 ));do
    ip=${hostlist[i]}
    username=${hostlist[i+1]}
    password=${hostlist[i+2]}
    port=${hostlist[i+3]}
    echo "${ip}" "${port}" "${username}"
    echo "${username}" "${password}"
    done

EOF