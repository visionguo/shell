#!/bin/bash

ts=`date +%s`;
endpoint=`hostname`

load1=`cat /proc/loadavg |awk '{print $1}'`
cpu=`cat /proc/cpuinfo| grep "processor"| wc -l`
loadcpu=`awk 'BEGIN{printf "%.3f\n",'$load1'/'$cpu'}'`

echo "[{\"endpoint\": \"$HOSTNAME\", \"timestamp\": `date +%s`, \"metric\": \"load.cpu\", \"value\": $loadcpu, \"counterType\": \"GAUGE\", \"step\": 60}]"
