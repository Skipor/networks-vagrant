#! /bin/bash
vagrant destroy /.+/ -f 
vagrant up --no-provision
vagrant provision --provision-with configure
