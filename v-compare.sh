#!/bin/bash
SCRIPT_NAME="${0##*/}"
info() {
	echo "${SCRIPT_NAME}: ${1}"
}

cat <<EOF
*****************************************************************
* If you have a cluster network policy, ensure that you allowed egress to 127.0.0.1/32 on port 988 for clusters running GKE versions prior to
1.21.0-gke.1000, or to 169.254.169.252/32 on port 988 for clusters running GKE version 1.21.0-gke.1000 and later.
* the Version 1.21.0-gke.1000
* Power by Lex. Let's go! and be happy!
* version 1.0
# we will define B and the value is 1.21.0-gke.1000 这个是有问题版本
# 大于或者等于这个版本都要去修复
# wget The a value is
# if A >=B  then upgrade master
*****************************************************************
EOF

function compare_version() {
	local VERSION=$1
	local VERSION2=$2
	function version_gt() { test "$(echo "$@" | tr " " "\n" | sort -V | head -n 1)" != "$1"; }
	function version_le() { test "$(echo "$@" | tr " " "\n" | sort -V | head -n 1)" == "$1"; }
	function version_lt() { test "$(echo "$@" | tr " " "\n" | sort -rV | head -n 1)" != "$1"; }
	function version_ge() { test "$(echo "$@" | tr " " "\n" | sort -rV | head -n 1)" == "$1"; }
	if version_gt "$VERSION" "$VERSION2"; then
		echo "$VERSION is greater than $VERSION2"
		echo "we need fix bugs"
		return 3
	fi

	if version_le "$VERSION" "$VERSION2"; then
		echo "$VERSION is less than or equal to $VERSION2"
		echo -e "\033[31m Because major version equal . Maybe we need fix bugs, we need checking the minor version \033[0m"
		info "get minor version and compare"
		if [ "$version_minor_A" -gt "$version_minor_B" ]; then
			echo "A > B"
			echo -e "\033[31m we need fix bugs \033[0m"
			return 3
		elif [ "$version_minor_A" -lt "$version_minor_B" ]; then
			echo "A < B"
			echo "Because A < B . we will ignore this bug"
		elif [ "$version_minor_A" -eq "$version_minor_B" ]; then
			echo "A = B"
			echo -e "\033[31m Because equal .we need fix bugs \033[0m"
			return 3
		fi
	fi

	if version_lt "$VERSION" "$VERSION2"; then
		echo "$VERSION is less than $VERSION2"
		echo "We can ingore this bug"
	fi
	#if version_ge $VERSION $VERSION2; then
	#   echo "$VERSION is greater than or equal to $VERSION2"
	#fi
}
info "The version B is 1.21.0-gke.1000 "
info "compare version"
version_A=1.21.0-gke.1001
version_B=1.21.0-gke.1000
#version_B=1.19.12-gke.2101
info "version_major compare"
version_major_A=$(echo $version_A | cut -d"-" -f1 | sort -V)
echo "$version_major_A"
version_major_B=$(echo $version_B | cut -d"-" -f1 | sort -V)
echo "$version_major_B"

info "will output A minor version"
version_minor_A=$(echo $version_A | awk -F"." '{print $NF}')
echo "$version_minor_A"
info "will output B minor version"
version_minor_B=$(echo $version_B | awk -F"." '{print $NF}')
echo "$version_minor_B"

compare_version "$version_major_A" "$version_major_B"

if [ $? = 3 ]; then
	echo "we need fix bugs"
	echo "execte your command"
else
	echo "we can ignore this bug"
fi

awk 'BEGIN{while (a++<50) s=s "-"; print s,"splite line",s}'
#currentver="$(gcc -dumpversion)"
currentver="$(echo $version_A | awk -F"-" '{print $1}')"
echo "$currentver"
requiredver="1.21.1"
if [ "$(printf '%s\n' "$requiredver" "$currentver" | sort -V | head -n1)" = "$requiredver" ]; then
	echo "Greater than or equal to ${requiredver}"
	# The next 直接字符串比较
	if [[ "$currentver" = "$requiredver" ]]; then
		echo "Equal to ${requiredver}"
	else
		echo "Greater than ${requiredver}"
	fi
else
	echo "Less than ${requiredver}"
fi

awk 'BEGIN{while (a++<50) s=s "-"; print s,"splite line",s}'

version_A=1.21.0-gke.1003
version_B=1.21.0-gke.1001

version_greater_equal() {
	printf '%s\n%s\n' "$2" "$1" | sort --check=quiet --version-sort
}

#version_greater_equal $version_A $version_B 大于或者等于的时候输出是0
# 当A小的时候输出是1
echo $version_A $version_B
version_greater_equal $version_A 1.21.0-gke.1004
#echo $?
if [ $? = 1 ]; then
	echo "A is less than B A<B "
else
	echo "A is greater than B A> B"
fi

awk 'BEGIN{while (a++<50) s=s "-"; print s,"splite line",s}'
echo "Checking A > B result"
version_greater_equal $version_A 1.21.0-gke.1002 || echo "A is less than B"
#echo $? 通过这个判断最终执行结果

awk 'BEGIN{while (a++<50) s=s "-"; print s,"splite line",s}'
echo "Checking A < B result"
version_greater_equal $version_A 1.21.0-gke.1004 || echo "A is less than B"

awk 'BEGIN{while (a++<50) s=s "-"; print s,"using x compare",s}'
info "compare version only A > B .But if A=B . it's bugs"

version_A=1.21.1-gke.1003
version_B=1.21.1-gke.1000

version_major_A=$(echo $version_A | cut -d"-" -f1 | sort -V)
echo "$version_major_A"
version_major_B=$(echo $version_B | cut -d"-" -f1 | sort -V)
echo "$version_major_B"

info "will output A minor version"
version_minor_A=$(echo $version_A | awk -F"." '{print $NF}')
echo "$version_minor_A"
info "will output B minor version"
version_minor_B=$(echo $version_B | awk -F"." '{print $NF}')
echo "$version_minor_B"

if [ x"$version_major_A" \> x"$version_major_B" ]; then
	echo "A is greater than B A > B"
else
	if [[ "$version_major_A" = "$version_major_B" ]]; then
		echo "A is equal to B A=B. So we need compare minor version"
		echo -e "\033[31m Because major version equal . Maybe we need fix bugs, we need checking the minor version \033[0m"
		info "get minor version and compare"
		if [ "$version_minor_A" -gt "$version_minor_B" ]; then
			echo "A > B"
			echo -e "\033[31m we need fix bugs \033[0m"
		elif [ "$version_minor_A" -lt "$version_minor_B" ]; then
			echo "A < B"
			echo "Because A < B . we will ignore this bug"
		elif [ "$version_minor_A" -eq "$version_minor_B" ]; then
			echo "A = B"
			echo -e "\033[31m Because equal .we need fix bugs \033[0m"
		fi
	else
		echo "A is less than B A < B"
	fi
fi

: <<EOF
echo 1.21.1 1.19.1 |tr " " "\n"
➜  shell echo 1.18.1 1.19.1 |tr " " "\n"|sort -V
1.18.1
1.19.1
➜  shell echo 1.18.1 1.19.1 |tr " " "\n"|sort -V|head -n 1
1.18.1
##大的在前面 然后取大的 如果相等,缺点就是如果相等
➜  shell printf '%s\n' 1.21.4 1.22.3|sort -V
1.21.4
1.22.3
➜  shell printf '%s\n' 1.21.4 1.22.3|sort -V|head -n 1
1.21.4

https://unix.stackexchange.com/questions/285924/how-to-compare-a-programs-version-in-a-shell-script

version_greater_equal()
{
    printf '%s\n%s\n' "$2" "$1" | sort --check=quiet --version-sort
}

version_greater_equal "${gcc_version}" 8.2 || die "need 8.2 or above"

https://stackoverflow.com/questions/4023830/how-to-compare-two-strings-in-dot-separated-version-format-in-bash



➜  shell printf '%s\n%s\n' 1.22.4-gke.1000 1.22.3|sort --check=quiet --version-sort
➜  shell echo $?
1
➜  shell printf '%s\n%s\n' 1.22.4-gke.1000 1.22.4|sort --check=quiet --version-sort
➜  shell echo $?
1
➜  shell printf '%s\n%s\n' 1.22.4-gke.1000 1.22.4-gke.1001|sort --check=quiet --version-sort
➜  shell echo $?
0
➜  shell printf '%s\n%s\n' 1.22.4-gke.1002 1.22.4-gke.1001|sort --check=quiet --version-sort
➜  shell echo $?
1


EOF
