e=hello-world
env=${e%-*}
apiRegion=${e#*-}
echo $env
echo $apiRegion


val="hello world!"

echo ${val#*o}
echo ${val##*o}


val="hello world!"

echo ${val%o*}
echo ${val%%o*}

${MODIFIED_PATH_TO_FILE}
val="hello world!"

echo ${val#*o}  # prints " world!"
echo ${val##*o}  # prints "ld!"

echo ${val%o*}  # prints "hello w"
echo ${val%%o*}  # prints "hell"


:<<EOF
进行字符串截取，%
第一个是从左到右进行删除第一个o的字符串。
第二个是从左到右进行删除最后一个o的字符串。
这里的 * 表示的是通配符


从右到左进行截取 #
从右向左进行截取到第一个o。
第二个说的是从右向左截取到最后一个o
EOF
