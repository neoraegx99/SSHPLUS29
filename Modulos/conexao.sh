#!/bin/bash
if [[ -e /usr/lib/licence ]]; then
ram1=$(free -h | grep -i mem | awk {'print $2'})
ram2=$(free -h | grep -i mem | awk {'print $4'})
ram3=$(free -h | grep -i mem | awk {'print $3'})
uso=$(top -bn1 | awk '/Cpu/ { cpu = "" 100 - $8 "%" }; END { print cpu }')
system=$(cat /etc/issue.net)
fun_bar () {
comando[0]="$1"
comando[1]="$2"
 (
[[ -e $HOME/fim ]] && rm $HOME/fim
[[ ! -d /etc/SSHPlus ]] && rm -rf /bin/menu
${comando[0]} > /dev/null 2>&1
${comando[1]} > /dev/null 2>&1
touch $HOME/fim
 ) > /dev/null 2>&1 &
 tput civis
echo -ne "\033[1;33mโปรดรอสักครู่... \033[1;37m- \033[1;33m["
while true; do
   for((i=0; i<18; i++)); do
   echo -ne "\033[1;31m#"
   sleep 0.1s
   done
   [[ -e $HOME/fim ]] && rm $HOME/fim && break
   echo -e "\033[1;33m]"
   sleep 1s
   tput cuu1
   tput dl1
   echo -ne "\033[1;33mโปรดรอสักครู่... \033[1;37m- \033[1;33m["
done
echo -e "\033[1;33m]\033[1;37m -\033[1;32m สำเร็จ !\033[1;37m"
tput cnorm
}

verif_ptrs () {
porta=$1
PT=$(lsof -V -i tcp -P -n | grep -v "ESTABLISHED" |grep -v "COMMAND" | grep "LISTEN")
for pton in `echo -e "$PT" | cut -d: -f2 | cut -d' ' -f1 | uniq`; do
    svcs=$(echo -e "$PT" | grep -w "$pton" | awk '{print $1}' | uniq)
    [[ "$porta" = "$pton" ]] && {
    	echo -e "\n\033[1;31mPORT \033[1;33m$porta \033[1;31mใช้งานโดย \033[1;37m$svcs\033[0m"
    	sleep 3
    	fun_conexao
    }
done
}

inst_sqd (){
if netstat -nltp|grep 'squid' 1>/dev/null 2>/dev/null;then
	echo -e "\E[41;1;37m            ลบ SQUID PROXY              \E[0m"
	echo ""
	echo -ne "\033[1;32mต้องการลบ SQUID \033[1;31m? \033[1;33m[y/n]:\033[1;37m "; read resp
	if [[ "$resp" = 'y' ]]; then
		echo -e "\n\033[1;32mลบ SQUID PROXY !\033[0m"
		echo ""
		rem_sqd () 
		{
		if [[ -d "/etc/squid/" ]]; then
			apt-get remove squid -y
			apt-get purge squid -y
			rm -rf /etc/squid
		fi
		if [[ -d "/etc/squid3/" ]]; then
			apt-get remove squid3 -y
			apt-get purge squid3 -y
			rm -rf /etc/squid3
		fi
	    }
	    fun_bar 'rem_sqd'
		echo -e "\n\033[1;32mลบ SQUID PROXY สำเร็จ !\033[0m"
		sleep 3.5s
		clear
		fun_conexao
	else
		echo -e "\n\033[1;31mกลับ...\033[0m"
		sleep 3
		clear
		fun_conexao
	fi
else
clear
echo -e "\E[44;1;37m              ติดตั้ง SQUID PROXY               \E[0m"
echo ""
IP=$(wget -qO- ipv4.icanhazip.com)
echo -ne "\033[1;32mกด Enter เพื่อยืนยัน IP คุณ: \033[1;37m"; read -e -i $IP ipdovps
if [[ -z "$ipdovps" ]];then
echo -e "\n\033[1;31mIP ไม่ถูกต้อง\033[1;32m"
echo ""
read -p "ป้อน IP ของคุณ: " IP
fi
echo -e "\n\033[1;33mPort ใดที่คุณต้องการใช้กับ SQUID \033[1;31m?"
echo -e "\n\033[1;33m[\033[1;31m!\033[1;33m] \033[1;32mกำหนด Port ตามลำดับ \033[1;33mEX: \033[1;37m80 8080 8799 3128"
echo ""
echo -ne "\033[1;32mPort\033[1;37m: "; read portass
if [[ -z "$portass" ]]; then
	echo -e "\n\033[1;31mPort ไม่ถูกต้อง!"
	sleep 3
	fun_conexao
fi
for porta in $(echo -e $portass); do
	verif_ptrs $porta
done
echo -e "\n\033[1;32mติดตั้ง SQUID PROXY\033[0m"
echo ""
fun_bar 'apt-get update -y' 'apt-get install squid3 -y'
sleep 1
if [[ -d "/etc/squid/" ]]; then
var_sqd="/etc/squid/squid.conf"
var_pay="/etc/squid/payload.txt"
elif [[ -d "/etc/squid3/" ]]; then
var_sqd="/etc/squid3/squid.conf"
var_pay="/etc/squid3/payload.txt"
fi
echo ".claro.com.br/
.claro.com.sv/
.facebook.net/
.netclaro.com.br/
.speedtest.net/
.tim.com.br/
.vivo.com.br/
.oi.com.br/" > $var_pay
echo "acl url1 dstdomain -i 127.0.0.1
acl url2 dstdomain -i localhost
acl url3 dstdomain -i $ipdovps
acl url4 dstdomain -i /SSHPLUS?
acl payload url_regex -i "$var_pay"
acl all src 0.0.0.0/0

http_access allow url1
http_access allow url2
http_access allow url3
http_access allow url4
http_access allow payload
http_access deny all
 
#Portas" > $var_sqd
for Pts in $(echo -e $portass); do
echo -e "http_port $Pts" >> $var_sqd
[[ -f "/usr/sbin/ufw" ]] && ufw allow $Pts/tcp
done
echo -e "
#Nome squid
visible_hostname OVPN-PRO 
via off
forwarded_for off
pipeline_prefetch off" >> $var_sqd
sqd_conf () {
if [[ -d "/etc/squid/" ]]; then
squid -k reconfigure
service ssh restart
service squid restart
elif [[ -d "/etc/squid3/" ]]; then
squid3 -k reconfigure
service ssh restart
service squid3 restart
fi
}
echo -e "\n\033[1;32mตั้งค่า SQUID PROXY\033[0m"
echo ""
fun_bar 'sqd_conf'
echo -e "\n\033[1;32mติดตั้ง SQUID PROXY เรียบร้อยแล้ว!\033[0m"
sleep 3.5s
fun_conexao
fi
}

addpt_sqd () {
	echo -e "\E[44;1;37m         เพื่อม Port Proxy         \E[0m"
	echo -e "\n\033[1;33mPort ใช้งาน: \033[1;32m$sqdp\n"
	if [[ -f "/etc/squid/squid.conf" ]]; then
		var_sqd="/etc/squid/squid.conf"
	elif [[ -f "/etc/squid3/squid.conf" ]]; then
		var_sqd="/etc/squid3/squid.conf"
	else
		echo -e "\n\033[1;31mไม่ได้ติดตั้ง SQUID PROXY!\033[0m"
		echo -e "\n\033[1;31mกลับ...\033[0m"
		sleep 2
		clear
		fun_squid
	fi
	echo -ne "\033[1;32mคุณต้องการเพิ่มพอร์ตใด\033[1;33m?\033[1;37m "; read pt
	if [[ -z "$pt" ]]; then
		echo -e "\n\033[1;31mPort ไม่ถูกต้อง!"
		sleep 3
		clear
		fun_conexao		
	fi
	verif_ptrs $pt
	echo -e "\n\033[1;32mเพิ่ม PORT PROXY!"
	echo ""
	sed -i "s/#Portas/#Portas\nhttp_port $pt/g" $var_sqd
	fun_bar 'sleep 2'
	echo -e "\n\033[1;32mรีเซ็ต SQUID!"
	echo ""
	fun_bar 'service squid restart' 'service squid3 restart'
	echo -e "\n\033[1;32mเพิ่อม PORT สำเร็จ!"
	sleep 3
	clear
	fun_squid
}

rempt_sqd () {
	echo -e "\E[41;1;37m        ลบ PORT PROXY        \E[0m"
	echo -e "\n\033[1;33mPORT ใช้งาน: \033[1;32m$sqdp\n"
	if [[ -f "/etc/squid/squid.conf" ]]; then
		var_sqd="/etc/squid/squid.conf"
	elif [[ -f "/etc/squid3/squid.conf" ]]; then
		var_sqd="/etc/squid3/squid.conf"
	else
		echo -e "\n\033[1;31mไม่ได้ติดตั้ง Squid Proxy!\033[0m"
		echo -e "\n\033[1;31mกลับ...\033[0m"
		sleep 2
		clear
		fun_squid
	fi
	echo -ne "\033[1;32mREMOVE PORT \033[1;33m?\033[1;37m "; read pt
	if [[ -z "$pt" ]]; then
		echo -e "\n\033[1;31mPort ไม่ถูกต้อง!"
		sleep 2
		clear
		fun_conexao
	fi
	if grep -E "$pt" $var_sqd > /dev/null 2>&1; then
		echo -e "\n\033[1;32mลบ PORT PROXY!"
		echo ""
		sed -i "/http_port $pt/d" $var_sqd
		fun_bar 'sleep 3'
		echo -e "\n\033[1;32mรีเซ็ต SQUID!"
		echo ""
		fun_bar 'service squid restart' 'service squid3 restart'
		echo -e "\n\033[1;32mลบ PORT สำเร็จ!"
		sleep 3.5s
		clear
		fun_squid
	else
		echo -e "\n\033[1;31mPORT \033[1;32m$pt \033[1;31mไม่พบ!"
		sleep 3.5s
		clear
		fun_squid
	fi
}

fun_squid () {
[[ "$(netstat -nplt |grep -c 'squid')" = "0" ]] && inst_sqd
echo -e "\E[44;1;37m          จัดการ SQUID PROXY           \E[0m"
[[ "$(netstat -nplt |grep -c 'squid')" != "0" ]] && {
sqdp=$(netstat -nplt |grep 'squid' | awk -F ":" {'print $4'} | xargs)
    echo -e "\n\033[1;33mPORT\033[1;37m: \033[1;32m$sqdp"
    VarSqdOn="ลบ SQUID PROXY"
} || {
    VarSqdOn="ติดตั้ง SQUID PROXY"
}
echo -e "\n\033[1;31m[\033[1;36m1\033[1;31m] \033[1;37m• \033[1;33m$VarSqdOn \033[1;31m
[\033[1;36m2\033[1;31m] \033[1;37m• \033[1;33mเพิ่ม PORT \033[1;31m
[\033[1;36m3\033[1;31m] \033[1;37m• \033[1;33mลบ PORT\033[1;31m
[\033[1;36m0\033[1;31m] \033[1;37m• \033[1;33mกลับ\033[0m"
echo ""
echo -ne "\033[1;32mChoose  \033[1;33m?\033[1;31m?\033[1;37m "; read x
clear
case $x in
	1|01)
	inst_sqd
	;;
	2|02)
	addpt_sqd
	;;
	3|03)
	rempt_sqd
	;;
	0|00)
	echo -e "\033[1;31mกลับ...\033[0m"
	sleep 1
	fun_conexao
	;;
	*)
	echo -e "\033[1;31mไม่ถูกต้อง...\033[0m"
	sleep 2
	fun_conexao
	;;
	esac
}

fun_drop () {
	if netstat -nltp|grep 'dropbear' 1>/dev/null 2>/dev/null;then
		clear
		[[ $(netstat -nltp|grep -c 'dropbear') != '0' ]] && dpbr=$(netstat -nplt |grep 'dropbear' | awk -F ":" {'print $4'} | xargs) || sqdp="\033[1;31mINDISPONIVEL"
        if ps x | grep "limiter"|grep -v grep 1>/dev/null 2>/dev/null; then
        	stats='\033[1;32m◉ '
        else
        	stats='\033[1;31m○ '
        fi
		echo -e "\E[44;1;37m              ตั้งค่า DROPBEAR               \E[0m"
		echo -e "\n\033[1;33mPORT\033[1;37m: \033[1;32m$dpbr"
		echo ""
		echo -e "\033[1;31m[\033[1;36m1\033[1;31m] \033[1;37m• \033[1;33mจำกัด DROPBEAR $stats\033[0m"
		echo -e "\033[1;31m[\033[1;36m2\033[1;31m] \033[1;37m• \033[1;33mเปลี่ยนพอร์ต DROPBEAR\033[0m"
		echo -e "\033[1;31
