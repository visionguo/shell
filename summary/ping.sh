##
#!/bin/bash
# Auther:Abel
# Date:2019/11/22

for ((i=0;i<10;i++));
do
  /usr/bin/nc -w 1 -v bjhw-bjks-online-iam0$i.bjhw $1
done

for ((i=10;i<15;i++));
do
  /usr/bin/nc -w 1 -v bjhw-bjks-online-iam$i.bjhw $1
done

##
#!/bin/bash
# Auther:Abel
# Date:2019/12/03

for ((i=0;i<10;i++));
do
  ping -c 1 -i 1 bjyz-bce-online-iam0$i.bjyz
done

for ((i=10;i<17;i++));
do
  ping -c 1 -i 1 bjyz-bce-online-iam$i.bjyz
done

#packet loss

#!/bin/sh
target_domain="www.baidu.com"

res=$( ping $target_domain -c 5 -w 3 | grep -oP ", (-?\\d+\\.\\d+|-?\\d+)% packet loss" | grep -oP "(-?\\d+\\.\\d+|-?\\d+)")
echo "bignat_err_percent_out: $res"
echo "BDEOF"


#ping domain timeout
#!/bin/bash

# Description: ping iam domain
# Author: guoshaogang@baidu.com
# Date: 2020-01-06

DATE=`date +%F" "%H:%M`
Domain="iam.fwh.bce.baidu-int.com"

while true
do
  time=$(ping $Domain -c 5 |grep avg |gawk -F "/" '{print $5}')
  Time=$(ping $Domain -c 5 |grep avg |gawk -F "/" '{print $5}' |awk -F "." '{print $1}')
  if [ $Time -gt 10 ]; then
    echo -e "Domain:$Domain  Timeout:$time  Date:$DATE  Problem:Ping Timeout!!!" >> /home/work/opdir/Abel/iam.fwh_timeout.txt
  fi
sleep 15
done
