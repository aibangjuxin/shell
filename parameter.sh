
#!/bin/bash
echo "the script's name"
echo $0
echo "The parameter one"
echo $1
echo "The parameter two"
echo $2
echo "参数nums:$#"
echo "*"$*
echo "for M in $*"
for M in $*
do
 echo $M
done
echo "@" $@

echo "for M in $@"
for M in $@
do
 echo $M
done

echo "传递参数作为1个字符串显示: $*"
for M in "$*"
do
 echo $M
done
echo "传递参数分开显示:$@"
for N in "$@"
do
 echo $N
done
echo "PID$$"
/usr/bin/java -version
echo $?


