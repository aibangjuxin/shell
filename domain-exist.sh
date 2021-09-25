#!/bin/bash
#zone=($(gcloud dns managed-zones list|awk 'NR!=1{print$1}'|grep private-access))
zone=($(gcloud dns managed-zones list --format="value(name)"))
#env-private-access
#private-access
echo "Determine whether the domain name exists"
for i in ${!zone[*]};do
     IFS=',' read -ra fn <<< "${zone[$i]}"
      fn_name=${fn[*]}
    #echo "The all of filename is $fn_name"
    for n in $fn_name;do
        while [ "$n" == "private-devenv-gcp-cloud-hsbc" ]
        do
            echo "The zone name have exist,so you cant't create it"
            echo "$n"
            exit 1
            break 3
        done
    done
done

if [[ $? == "1" ]]; then
      echo "The zone name exits"
      exit 1
fi

echo "contain create you zone name"


zone_name_lists=(`gcloud dns managed-zones list --format="value(name)"`)
    for (( i=1; i<${#zone_name_lists[@]}; i++ ))
    do
        zone_name=${zone_name_lists[i]}
        echo "zone_name:${zone_name}"
done


:<<EOF
zone_name_lists=($(gcloud dns managed-zones list --format="value(name)"))
#env-private-access
#private-access
echo "Determine whether the domain name exists"
    for (( i=1; i<${#zone_name_lists[@]}; i++ ))
    do
        zone_name=${zone_name_lists[i]}
        for n in $zone_name;do
            while [ "$n" == "private-devenv-gcp-cloud-hsbc" ]
            do
                echo "The zone name have exist,so you cant't create it"
                echo "$n"
                exit 1
                break 3
            done
        done
    done

zone_name_lists=($(gcloud dns managed-zones list --format="value(name)"))
old_name_lists=(private-devenv-gcp-cloud-hsbc env-private-access)
#echo zone_name_lists=${zone_name_lists[@]}
#echo old_name_lists=${old_name_lists[@]}
for i in ${zone_name_lists[@]};do
  for j in ${old_name_lists[@]};do
    if [ $i == $j ];then
      echo -e "\033[32m same number is $i \033[0m"
      echo "you cant't crete $i"
      exit 1
    fi
  done
done


EOF
