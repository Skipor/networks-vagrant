#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color
if [ "$#" -ne 3 ]; then
    echo "${RED}Ошибка: неверное количество параметров${NC}"
    echo "Usage: sudo sh install_router.sh ИНТЕРФЕЙС_РОУТЕРА НОМЕР_РОУТЕРА КОЛИЧЕСТВО_РОУТЕРОВ"
    exit 1
fi
router_interface=$1
router_number=$2
total_number=$3

next_number=$(( (router_number - 1 + 1) % total_number + 1 ))
prev_number=$(( (router_number - 1 - 1 + total_number) % total_number + 1 ))

echo "${YELLOW}##### Проверяем окружение #####${NC}"
# ip addr flush dev $router_interface
echo "${GREEN}### Включаем IP Forwarding ###${NC}"
echo 1 > /proc/sys/net/ipv4/ip_forward
echo "${GREEN}### Устанавливаем ПО ###${NC}"
#sudo apt-get install vlan quagga bridge-utils
echo "${GREEN}### Проверяем 8021q ###${NC}"
sudo modprobe 8021q
lsmod | grep 8021q
echo "${YELLOW}##### Настройки #####${NC}"
echo "${BLUE}Интерфейс     =${NC} ${router_interface}"
echo "${BLUE}Номер роутера =${NC} ${router_number}"
nextwork_prefix='192.168'

vlan_create() {
	echo "${YELLOW}##### Создаем VLAN ${1} #####${NC}"
	vconfig add $router_interface $1
}

vlan_up() {
	echo "${YELLOW}##### Запускаем VLAN ${2} #####${NC}"
	current_vlan=$2;
	vconfig add $router_interface $current_vlan
	current_address=$nextwork_prefix.$current_vlan.$1
	echo "${GREEN}### Присваиваем интерфейсу VLAN ${2} адрес ${current_address}/24 ###${NC}"
	ifconfig $router_interface.$current_vlan $current_address/24 up
	echo "${GREEN}### Проверяем VLAN ${2} ###${NC}"
	ifconfig -a | grep $router_interface.$current_vlan -A 5
}

#bridge_create() {
#	echo "${YELLOW}##### Создаем мост между VLAN ${1} и ${2} #####${NC}"
#	current_bridge=vlan_br
#	echo "${GREEN}### Создаем мост ###${NC}"
#	brctl addbr $current_bridge
#	echo "${GREEN}### Подключаем к мосту интерфейсы от VLAN ###${NC}"
#	brctl addif $current_bridge $router_interface.$1
#	brctl addif $current_bridge $router_interface.$2
#	echo "${GREEN}### Включаем у моста Spanning tree протокол ###${NC}"
#	brctl stp $current_bridge on
#	echo "${GREEN}### Проверяем мост ${current_bridge} ###${NC}"
#	brctl show
#}

#bridge_up() {
#	current_address=$nextwork_prefix.111.$router_number
#	echo "${YELLOW}##### Запускаем мост ${current_bridge} с адресом ${current_address}/24 #####${NC}"
#	ifconfig $current_bridge up
#	echo "${GREEN}### Проверяем мост ###${NC}"
#	ifconfig -a | grep $current_bridge -A 5
#}

next_vlan=$router_number$next_number
vlan_create $next_vlan

prev_vlan=$prev_number$router_number
vlan_create $prev_vlan

client_vlan=$router_number$router_number
vlan_create $client_vlan

#echo "${YELLOW}##### Запускаем алиас ${router_interface}:1 с адресом ${nextwork_prefix}.${router_number}${router_number}0.1/24 #####${NC}"
#ifconfig $router_interface:1 $nextwork_prefix.${router_number}${router_number}0.1/24 up

# bridge_create $prev_vlan $next_vlan

vlan_up $router_number $next_vlan
vlan_up $router_number $prev_vlan
vlan_up 1 $client_vlan

# bridge_up $prev_vlan $next_vlan

echo 1 > /proc/sys/net/ipv4/conf/$router_interface.$next_vlan/proxy_arp
echo 1 > /proc/sys/net/ipv4/conf/$router_interface.$prev_vlan/proxy_arp
echo 1 > /proc/sys/net/ipv4/conf/vlan_br/proxy_arp

echo "${YELLOW}##### Настройка ripd.conf #####${NC}"
echo "${GREEN}### Добавляем пароль: zebra ###${NC}"
echo "hostname ripd" > /etc/quagga/ripd.conf
echo "password zebra" >> /etc/quagga/ripd.conf

echo "${GREEN}### Включаем логгирование в /var/log/quagga/ripd.log ###${NC}"
echo "log file /var/log/quagga/ripd.log" >> /etc/quagga/ripd.conf

echo "${GREEN}### Добавляем подсети интерфейсов VLAN ###${NC}"
echo "router rip" >> /etc/quagga/ripd.conf
echo " version 2" >> /etc/quagga/ripd.conf
echo " timers basic 5 10 10" >> /etc/quagga/ripd.conf
echo " network ${router_interface}.${next_vlan}" >> /etc/quagga/ripd.conf
echo " network ${router_interface}.${prev_vlan}" >> /etc/quagga/ripd.conf
echo " network ${router_interface}.${client_vlan}" >> /etc/quagga/ripd.conf
#echo " network ${router_interface}:1" >> /etc/quagga/ripd.conf
#echo " network ${nextwork_prefix}.${next_number}0.0/24" >> /etc/quagga/ripd.conf
#echo " network ${nextwork_prefix}.${prev_number}0.0/24" >> /etc/quagga/ripd.conf
#echo " network ${nextwork_prefix}.${next_vlan}.0/24" >> /etc/quagga/ripd.conf
#echo " network ${nextwork_prefix}.${prev_vlan}.0/24" >> /etc/quagga/ripd.conf
#echo " network ${nextwork_prefix}.${router_number}0.0/24" >> /etc/quagga/ripd.conf

echo "line vty" >> /etc/quagga/ripd.conf

echo "${YELLOW}##### Настройка zebra.conf #####${NC}"
echo "hostname Router${router_number}" > /etc/quagga/zebra.conf
echo "${GREEN}### Добавляем пароль: zebra ###${NC}"
echo "password zebra" >> /etc/quagga/zebra.conf
echo "enable password zebra" >> /etc/quagga/zebra.conf
echo "${GREEN}### Включаем логгирование в /var/log/quagga/zebra.log ###${NC}"
echo "log file /var/log/quagga/zebra.log" >> /etc/quagga/zebra.conf

#echo "${GREEN}### Добавляем интерфейсы VLAN ###${NC}"
#echo "interface ${router_interface}" >> /etc/quagga/zebra.conf 
#echo " no link-detect" >> /etc/quagga/zebra.conf
#echo " ipv6 nd suppress-ra" >> /etc/quagga/zebra.conf

#echo "interface vlan_br" >> /etc/quagga/zebra.conf 
#echo " no link-detect" >> /etc/quagga/zebra.conf
#echo " ipv6 nd suppress-ra" >> /etc/quagga/zebra.conf

#echo "interface ${router_interface}.${next_vlan}" >> /etc/quagga/zebra.conf
#echo " no link-detect" >> /etc/quagga/zebra.conf
#echo " ip address ${nextwork_prefix}.${next_vlan}.${router_number}/24" >> /etc/quagga/zebra.conf
#echo " ipv6 nd suppress-ra" >> /etc/quagga/zebra.conf

#echo "interface ${router_interface}.${prev_vlan}" >> /etc/quagga/zebra.conf
#echo " no link-detect" >> /etc/quagga/zebra.conf
#echo " ip address ${nextwork_prefix}.${prev_vlan}.${router_number}/24" >> /etc/quagga/zebra.conf
#echo " ipv6 nd suppress-ra" >> /etc/quagga/zebra.conf

#echo "interface ${router_interface}:1" >> /etc/quagga/zebra.conf
#echo " no link-detect" >> /etc/quagga/zebra.conf
#echo " ip address ${nextwork_prefix}.${router_number}0.1/24" >> /etc/quagga/zebra.conf
#echo " ipv6 nd suppress-ra" >> /etc/quagga/zebra.conf

echo "ip forwarding" >> /etc/quagga/zebra.conf
echo "line vty" >> /etc/quagga/zebra.conf

echo "${YELLOW}##### Меняем права и владельцев файлов настроек Quagga #####${NC}"
chown quagga.quaggavty /etc/quagga/*.conf
chmod 640 /etc/quagga/*.conf

echo "${YELLOW}##### Делаем рестарт сервиса Quagga #####${NC}"
/etc/init.d/quagga restart




