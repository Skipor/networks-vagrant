#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

if [ "$#" -ne 3 ]; then
	echo "${RED}Ошибка: неверное количество параметров${NC}"
	echo "Usage: sudo sh install_client.sh ИНТЕРФЕЙС_КЛИЕНТА НОМЕР_КЛИЕНТА НОМЕР_РОУТЕРА"
	exit 1
fi

client_interface=$1
client_number=$2
router_number=$3

network_prefix='192.168'

router_address=$network_prefix.$router_number$router_number.1

client_vlan=$router_number$router_number

echo "${YELLOW}##### Проверяем окружение #####${NC}"
# ip addr flush dev $client_interface
echo "${GREEN}### Включаем IP Forwarding (необязательно) ###${NC}"
echo 1 > /proc/sys/net/ipv4/ip_forward
echo "${GREEN}### Устанавливаем ПО ###${NC}"
#sudo apt-get install vlan quagga bridge-utils
echo "${GREEN}### Проверяем 8021q ###${NC}"
sudo modprobe 8021q
lsmod | grep 8021q

echo "${YELLOW}##### Настройки #####${NC}"
echo "${BLUE}Интерфейс 	=${NC} ${client_interface}"
echo "${BLUE}Номер роутера =${NC} ${router_number}"
echo "${BLUE}Адрес роутера =${NC} ${router_address}"
echo "${BLUE}Тег VLAN  	=${NC} ${client_vlan}"

echo "${YELLOW}##### Поднимаем VLAN #####${NC}"
echo "${GREEN}### Создаем VLAN ${client_vlan} ###${NC}"
vconfig add $client_interface $client_vlan

client_address=$network_prefix.$router_number$router_number.$client_number
echo "${GREEN}### Присваиваем интерфейсу VLAN ${2} адрес ${client_address}/24 ###${NC}"
ifconfig $client_interface.$client_vlan $client_address/24 up

echo "${GREEN}### Проверяем VLAN ${client_vlan} ###${NC}"
ifconfig -a | grep $client_interface.$client_vlan -A 5

echo "${YELLOW}##### Настройка таблицы маршрутизации #####${NC}"
echo "${GREEN}### Удалем лишние default gateway из таблицы маршрутизации ###${NC}"
route del -net default dev $client_interface

echo "${GREEN}### Устанавливаем адрес роутера ${router_address} как default gateway через VLAN ${client_vlan} ###${NC}"
#echo "route add -net default gw ${router_address} dev ${client_interface}.${client_vlan}"
route add -net default gw $router_address dev $client_interface.$client_vlan

echo "${GREEN}### Направляем 192.168.0.0/16 через адрес роутера ${router_address} через VLAN интерфейс ${client_interface}.${client_vlan} ###${NC}"
ip route add 192.168.0.0/16 via $router_address dev $client_interface.$client_vlan

echo "${GREEN}### Проверяем таблицу маршрутизации ###${NC}"
netstat -rn




