1、#取出域名并进行计数排序
Q:  
    http://www.baidu.com/guding/more.htmlhttp://www.baidu.com/events/20060105/photomore.htmlhttp://hi.baidu.com/browse/http://www.sina.com.cn/head/www20021123am.shtmlhttp://www.sina.com.cn/head/www20041223am.shtml

A:  
    cat awk.sh |awk -F "http://" '{for (i=1;i<=NF;i++) print$i}' |awk -F "/" '{print $1}' |grep -v '^$' |uniq -c |sort -nr

2、#把0123456789作为基准的字串字符表,产生一个6位的字串642031,打印出的字串为 130246
    awk -v count=6 'BEGIN {srand();str="0123456789";len=length(str);for(i=count;i>0;i--) marry[i]=substr(str,int(rand()*len),1);for(i=count;i>0;i--) printf("%c",marry[i]);printf("\n");for(i=0;i<=count;i++) printf("%c",marry[i]);printf("\n")}'

3、将文本的奇数行和偶数行合并
    sed -n -e 2p -e 3p test.sh |sed '$!N;s/\n//g' test.sh

4、http的并发请求数与其TCP连接状态
    ss -n | awk '/^tcp/ {++S[$NF]} END {for(a in S) print a, S[a]}'
	
    ###tcpdump###
5、用tcpdump嗅探80端口的访问看看谁最高
    tcpdump -i eth0 -tnn dst port 80 -c 1000 | awk -F"." '{print $1"."$2"."$3"."$4}'| sort | uniq -c | sort -nr |head -20 
6、使用tcpdump监听主机为192.168.1.1，tcp端口为80的数据
    tcpdump 'host 192.168.1.1 and port 80' > tcpdump.log
7、 实时抓取并显示当前系统中tcp 80端口的网络数据信息
    tcpdump -nn tcp port 80

8、将本地80 端口的请求转发到8080 端口
    iptables -A PREROUTING -d 192.168.2.1 -p tcp -m tcp -dport 80 -j DNAT-to-destination 192.168.2.1:8080
    
