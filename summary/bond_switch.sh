#!/bin/bash
#added by xxx at 2016-07-30
#add function to check mode of switch

MODE=4
DATE=$(date +'%m-%d')
GATEWAY=$(route | grep -E '10.0.0.0|default' | awk '{print $2}' | head -1)
LOG_FILE="/var/tmp/bond_"$DATE".log"

function Check_Bond_Card(){
    echo 'Check network cards...'
    chkmode=`cat /sys/class/net/bond0/bonding/mode 2>/dev/null | awk '{print $2}'`
    cnt=$(cat /proc/net/bonding/bond0 2>/dev/null | grep 'MII Status: up' | wc -l)
    if [[ $chkmode -eq 2 ]];then
        if [ x"$cnt" == "x3" ];then
            echo "Before Bond : The server has been bond 2, exit 1" >> $LOG_FILE
	    return 1
        else
	    echo "Before Bond : The server has been bond 2, but one card is down, exit 1" >> $LOG_FILE
	    return 1
	fi
    elif [[ $chkmode -eq 4 ]];then
        if [ x"$cnt" == "x3" ];then
            echo "Server has been bond 4, exit 0"
            exit 0
        else
            echo "Before Bond : The server has been bond 4, but one card is down, exit 1" >> $LOG_FILE
            return 1
        fi
    fi
    cnt=$(ifconfig -a |grep xgbe* |wc -l)
    if [ $cnt -lt 2 ];then
        echo "Before Bond : The server has less then 2 card" >> $LOG_FILE
        return 1
    fi
    ls /var/tmp/ifcfg-bond0* 2>/dev/null
    if [ $? -eq 0 ];then
        echo "Before Bond : The server has config bond and fail, exit 1"  >> $LOG_FILE
        return 1
    fi

    for iface in xgbe0 xgbe1
    do
        ifconfig $iface up
        if [ $? -eq 0 ];then
            sleep 10
            no_link=$(ethtool $iface |grep "Link detected: yes")
            no_carrier=$(ip link show |grep "${iface}.*NO-CARRIER")
            if [ x"$no_link" == "x" -o x"$no_carrier" != "x" ];then
                echo "Before Bond : The server's card status error, exit 1" >> $LOG_FILE
                ifconfig $iface down
                return 1
            fi
        fi
    done
}

function Config_Route(){
    route add -net 10.0.0.0/8 gw $GATEWAY
    route add -net 100.64.0.0/10 gw $GATEWAY
    route add -net 172.16.0.0/12 gw $GATEWAY
    route add -net 192.168.0.0/16 gw $GATEWAY
}

function Make_Bond(){
    echo 'Start to make bond...'
    local ip=`ifconfig | grep "inet addr:10" | awk -F"inet addr:" '{print $2}' | awk '{print $1}'`
    local netmask=`ifconfig | grep "inet addr:10" | awk -F"Mask:" '{print $2}'`

    [ -f /etc/sysconfig/network-scripts/ifcfg-bond0 ] && cp /etc/sysconfig/network-scripts/ifcfg-bond0 /var/tmp/ifcfg-bond0

    if [[ -f /etc/sysconfig/network-scripts/ifcfg-xgbe0 ]];then
	cp /etc/sysconfig/network-scripts/ifcfg-xgbe0 /var/tmp/ifcfg-xgbe0
    else
        echo -e "\033[31m/etc/sysconfig/network-scripts/ifcfg-xgbe0\033[0m not found!"
        exit 1
    fi

    if [[ -f /etc/sysconfig/network-scripts/ifcfg-xgbe1 ]];then
	cp /etc/sysconfig/network-scripts/ifcfg-xgbe1 /var/tmp/ifcfg-xgbe1
    else
        echo -e "\033[31m/etc/sysconfig/network-scripts/ifcfg-xgbe1\033[0m not found!"
        exit 1
    fi

    if [[ -f /etc/modprobe.d/dist.conf ]];then
	cp /etc/modprobe.d/dist.conf /var/tmp/dist.conf
    else
        echo -e "\033[31m/etc/modprobe.d/dist.conf\033[0m not found!"
        exit 1
    fi

###create ifcfg-bond0
echo "
DEVICE=bond0
MTU=2000
BOOTPROTO=static
IPADDR=$ip
NETMASK=$netmask
ONBOOT=yes
USERCTL=no" > /etc/sysconfig/network-scripts/ifcfg-bond0
echo "
DEVICE=xgbe0
MTU=2000
BOOTPROTO=none
ONBOOT=yes
MASTER=bond0
SLAVE=yes
USERCTL=yes" > /etc/sysconfig/network-scripts/ifcfg-xgbe0
###modify ifcfg-xgbe1
echo "
DEVICE=xgbe1
MTU=2000
BOOTPROTO=none
ONBOOT=yes
MASTER=bond0
SLAVE=yes
USERCTL=yes" > /etc/sysconfig/network-scripts/ifcfg-xgbe1
    if [ -z "`grep -E '^alias bond0 bonding' /etc/modprobe.d/dist.conf`" ];then
        echo "alias bond0 bonding" >> /etc/modprobe.d/dist.conf
    fi
    if [ -z "`grep -E '^options bond' /etc/modprobe.d/dist.conf`" ];then
        echo "options bonding miimon=100 mode=$MODE xmit_hash_policy=layer3+4" >> /etc/modprobe.d/dist.conf
    else
        sed -i "s/options bond.*/options bonding miimon=100 mode=$MODE xmit_hash_policy=layer3+4/" /etc/modprobe.d/dist.conf
    fi
    rmmod bonding
    sleep 10
    modprobe bonding
    service network restart
    Config_Route
    }

function Check_Bond(){
    echo 'Check bond...'
    # the step 1 check
    cat /sys/class/net/bond0/bonding/mode
    if [ $? -ne 0 ];then
        echo "After Bond : The bond config error, exit 1"  >> $LOG_FILE
        return 1
    fi
    #the step 2 check
    for iface in xgbe0 xgbe1
    do
        if  ! ifconfig $iface | grep UP ; then
            echo "-----------------node --------------"
            ifconfig $iface up && sleep 5
        fi
        no_link=$(ethtool $iface |grep "Link detected: yes")
        no_carrier=$(ip link show |grep "${iface}.*NO-CARRIER")
        if [ x"$no_link" == "x" -o x"$no_carrier" != "x" ];then
            echo "After Bond : The server's card status error, exit 1" >> $LOG_FILE
            return 1
        fi
    done
    #the step 3 check
    cnt=$(cat /proc/net/bonding/bond0  | grep 'MII Status: up' | wc -l)
    if [ x"$cnt" != "x3" ];then
        echo "After Bond:The up card num error, exit 1"  >> $LOG_FILE
        return 1
    fi
    ping -c 5 $GATEWAY
    if [ $? -ne 0 ];then
        echo "Ping gateway failed, exit 1"  >> $LOG_FILE
        return 1
    fi
}

function Rollback_Bond(){
    echo 'Rollback bond...'
    [ -f /var/tmp/ifcfg-xgbe0 -a -f /var/tmp/ifcfg-xgbe1 -a -f /var/tmp/dist.conf ] || exit 1
    mv /etc/sysconfig/network-scripts/ifcfg-xgbe0 /tmp/
    mv /etc/sysconfig/network-scripts/ifcfg-xgbe1 /tmp/
    mv /etc/sysconfig/network-scripts/ifcfg-bond0 /tmp/
    mv /var/tmp/ifcfg-xgbe0 /etc/sysconfig/network-scripts/ifcfg-xgbe0
    mv /var/tmp/ifcfg-xgbe1 /etc/sysconfig/network-scripts/ifcfg-xgbe1
    mv /var/tmp/dist.conf /etc/modprobe.d/dist.conf
    [ -f /var/tmp/ifcfg-bond0 ]
    if [ $? -eq 0 ];then
        mv /var/tmp/ifcfg-bond0 /etc/sysconfig/network-scripts/ifcfg-bond0
        rmmod bonding
        sleep 10
        modprobe bonding
    else
        rmmod bonding
    fi
    service network restart
    Config_Route
}

function main(){
    echo "Begin to make bond..." >> $LOG_FILE
    echo -e "Begin ipconfig info:\n" >> $LOG_FILE
    ifconfig >> $LOG_FILE
    Check_Bond_Card
    if [ $? -ne 0 ];then
        echo "Pre check failed, log :" $LOG_FILE
        exit 1
    fi
    Make_Bond
    sleep 2
    Check_Bond
    if [ $? -ne 0 ];then
        echo "Make bond error, log :" $LOG_FILE
        Rollback_Bond
        if [ $? -eq 0 ];then
            echo "Rollback bond successful." >> $LOG_FILE
        else
            echo "Rollback bond error." >> $LOG_FILE
        fi
        exit 1
    fi
    echo -e "After make bond ipconfig info:\n" >> $LOG_FILE
    ifconfig >> $LOG_FILE
    echo -e "\033[32mMake bond successful.\033[0m"
}

main

