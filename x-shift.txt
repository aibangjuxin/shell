#!/bin/bash
echo $#

function usage() {
  echo "Examples:"
  echo "  $0 -s pdev"
  exit 1
}

if [ $# -eq 0 ];
then
    usage
    exit
fi

until [ $# -eq 0 ]
do
echo "第一个参数为: $1 参数个数为: $#"
if [ $1 == "hello" ];then
    echo "hello world"
fi
shift
done

:<<EOF
shift 命令每执行一次，变量的个数($#)减一，而变量值提前一位
　Shift 命令一次移动参数的个数由其所带的参数指定。例如当 shell 程序处理完前九个命令行参数后，可以使用 shift 9 命令把 $10 移到 $1。
Shell 传递参数
我们可以在执行 Shell 脚本时，向脚本传递参数，脚本内获取参数的格式为：$n。n 代表一个数字，1 为执行脚本的第一个参数，2 为执行脚本的第二个参数，以此类推……
echo $n    # 传递给脚本或函数的参数。n 是一个数字，表示第几个参数。例如，第一个参数是 $1 。
EOF
