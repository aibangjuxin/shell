#!/bin/bash
cd /Users/lex/shell || return
#array=(`ls -al|grep ^-|awk '{print$NF}'`) # array=($(ls))
array=($(ls))
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

echo "////判断要找的某个文件在不在？//////////////"
echo "${array[*]}"|grep rsync-onedrive.sh

if [[ $? == 1 ]]; then
    echo "you need file rsync-onedrive.sh not found"
    exit 1
else
    echo "the file rsync-onedrive.sh exists"
fi

:<<EOF
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
