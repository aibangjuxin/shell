#!/bin/bash
cd /Users/lex/shell || return
#array=(`ls -al|grep ^-|awk '{print$NF}'`) # array=($(ls))
array=($(ls))
IFS=$'\t' read -r -a AWS_STS_CREDS <<< "$(ls -al)"
#${#array[@]}数组元素的个数： 利用这可以去做循环
echo "Array contains ${#AWS_STS_CREDS[@]} elements" #Array contains 1 elements
echo "${AWS_STS_CREDS[0]}" #total 844
echo "${AWS_STS_CREDS[*]}"
echo "+++++++++++++++++++++++"
echo "print \$array Expanding an array without an index only gives the first element"
echo "$array"

echo "print \${array[*]}"
echo "${array[*]}"

echo "print \${array[@]}"
echo "${array[@]}"

echo "print The number of array \${#array[*]}"
echo "The number of array ${#array[*]}"

echo "print The number of array \${#array[@]}"
echo "The number of array ${#array[@]}"


for i in ${!array[*]};do
    IFS=',' read -ra fn <<< "${array[$i]}"
    fn_name=${fn[*]}
    echo "The all of filename is $fn_name"
done


 echo "#列出所有键值对"
 for key in "${!array[@]}"
 do
     echo "${key} -> ${array[$key]}"
 done


echo "////判断要找的某个文件在不在？//////////////"
echo "${array[*]}"|grep rsync-onedrive.sh

if [[ $? == 1 ]]; then
    echo "you need file rsync-onedrive.sh not found"
    exit 1
else
    echo "the file rsync-onedrive.sh exists"
fi

:<<EOF

cd /Users/lex/shell || return
array=($(ls -l|awk 'NR!=1{print$NF}'))
echo "$array"
echo "+++++++++++++"
array=($(ls))
echo "print \$array Expanding an array without an index only gives the first element 数组扩展一个没有索引的数组只会得到第一个元素"
echo "$array"
echo "+++++++++++++"
echo "print \${array[*]} @和*的作用相同，均是打印出所有元素"
echo "+++++++++++++"
echo "${array[*]}"
echo "+++++++++++++"
IFS=$'\t' read -r -a AWS_STS_CREDS <<< "$(ls)"
echo "Array contains ${#AWS_STS_CREDS[@]} elements" #Array contains 1 elements
echo "${AWS_STS_CREDS[0]}" 
echo "${AWS_STS_CREDS[*]}"
echo "+++++循环打印出来所有的++++++++"
while IFS=$'\t' read -r -a AWS_STS_CREDS
do 
echo "${AWS_STS_CREDS[*]}"
#echo "${#AWS_STS_CREDS[*]}" #写在这里仅仅结果是1的
done <<< "$(ls)" 
echo "============"
#${#array[@]}数组元素的个数： 利用这个个数可以去做循环也是一种办法
echo "${#array[@]}"
for((i=0;i<=${#array[@]};i++))
do 
#echo $i
echo "${array[i]}"
done


 echo "#列出所有键值对 key是数字下标"
 for key in "${!array[@]}"
 do
     echo "${key} -> ${array[$key]}"
 done

array=($(ls))
       ^---^ SC2207: Prefer mapfile or read -a to split command output (or quote to avoid splitting).

1 数组的定义：直接括号开始
eg: The line 3 and 4
动态定义数组变量，并使用命令的输出结果作为数组的内容

2 数组的打印和输出 ${array[*]} ${array[@]} @和*的作用相同，均是打印出所有元素
eg: The line 9 and 12

3 打印元素个数
eg: The line 15 and 18

4 对关联数组的遍历 The line 21
${!array[*]} 获取的是关联数组的所有下标值组成的数组

read -ra : 分配给新的数组 fn
-r：不允许反斜杠来转义任何字符
-a array：把输入内容按分隔符(空格或者跳格之类)分配给数组 这里是 IFS=','
<<< 可以将标准输入流重定向

5 将新的数组 fn 赋值给变量fn_name

EOF
