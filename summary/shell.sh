#重命名命令
alias ls = ‘rm -rf /‘  

#摇骰子
init `echo ((RANDOM%6))`

#echo.sh
for i in $(seq 1 100000)
do
   echo $HOSTNAME
   sleep 1
done

#在1-39内取随机数
expr $[RANDOM%39] +1
RANDOM随机数
%39取余数范围0-38 
