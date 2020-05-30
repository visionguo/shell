1、每天早上5点做备份，备份/var/mylog里所有文件和目录，压缩保留到一台ftp服务器上
#!/bin/bash

bakdir=mylog
date=`date +%F`
cd /var
tar -zcf ${bakdir}_${date}.tar.gz ${bakdir}
sleep 1

ftp -n <<-EOF
open 192.168.1.1
user aaa bbb
put mylog_*.tar.gz
bye 
EOF

rm -fr mylog_*.tar.gz


#
00 05 * * * /bin/bash xxx.sh &>/dev/null
