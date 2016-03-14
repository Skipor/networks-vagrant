#!/bin/bash - 
sudo apt-get clean

#“zero out” the drive (this is for Ubuntu)
#sudo dd if=/dev/zero of=/EMPTY bs=1M
#sudo rm -f /EMPTY


cat /dev/null > ~/.bash_history && history -c && exit 



