#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

if [ "$#" -ne 3 ]; then
    echo "${RED}Ошибка: неверное количество параметров${NC}"
    echo "Usage: sudo sh create_client.sh ИНТЕРФЕЙС_КЛИЕНТА НОМЕР_КЛИЕНТА НОМЕР_РОУТЕРА"
    exit 1
fi

client_interface=$1
client_number=$2
router_number=$3

client_vlan=$router_number$router_number

echo "${YELLOW}##### Проверяем окружение #####${NC}"
echo "${GREEN}### Устанавливаем ПО ###${NC}"
#sudo apt-get install vlan
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

#original
sleep 0.5 
echo "${GREEN}### Поднимаем интерфейс с IPv4 адресом (необязательно) ###${NC}"
ifconfig $client_interface.$client_vlan 192.168.$client_vlan.$client_number up
sleep 0.5

echo "${YELLOW}##### Настройка таблицы маршрутизации #####${NC}"
echo "${GREEN}### Устанавливаем default gateway IPv6 ###${NC}"
route -A inet6 add fc00:192:168::/48 gw fc00:192:168:$client_vlan::1 dev $client_interface.$client_vlan

echo "${GREEN}### Проверяем таблицу маршрутизации ###${NC}"
netstat -6rn
