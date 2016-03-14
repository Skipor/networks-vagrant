#!/bin/bash
RED='\033[0;31m'
NC='\033[0m' # No Color

if [ "$#" -ne 1 ]; then
	echo "${RED}Ошибка: неверное количество параметров${NC}"
	echo "Usage: make_box.sh <boxname>"
	exit 1
fi

box_name=$1

vagrant provision --provision-with make_small
rm -f $box_name.box
vagrant package --output $box_name.box
vagrant box add $box_name  $box_name.box
vagrant halt





