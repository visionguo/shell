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
