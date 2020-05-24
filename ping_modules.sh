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
