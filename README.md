## Vagrant environment for networks course labs
### Vagrant
* Vagrant is a tool for building and distributing development environments
	* dowload it from package manager or [from site](https://www.vagrantup.com/downloads.html)
	* [vagrant getting started](https://www.vagrantup.com/docs/getting-started/)
* environment configuration desribed in Vagrantfile's
	* they are ruby scrips, so you can write real program 
* Vagrant Comand Line Interface is not complex, but there are bash scripts in `./manage` folder for almost all basic needs. Warning!! use them from repo folder, as `./manage/start.sh`

* To start download Vagrant, clone repo, cd to repo folder, `./manage/start.sh` or `vagrant up`
	* see scripts in `./manage` folder or `vagrant help` to know what you can
	* `./manage/ssh.sh router-1` or `vagrant ssh router-1` for connecting to `router-1` machine, and any other same way
* We are using virtualbox provider, so every Vagrant machine is virtualbox machine
	
### Main environment 
* Main Vagrantfile defines several machines.
* There some variables that describe environment
	* `routers_count` and `nodes_count` defines machines number
		* routers have names from `router-1` to `router-#{router_count}`
		* clients have names from `node-1-2` to `node-#{router_count}-#{nodes_count + 1}`
		* for example with `routers_count = 2` and `nodes_count = 2` there will be 4 machines
			* `router-1 node-1-2 node-1-3`
			* `router-2 node-2-2 node-2-3`
		* machine Vagrant names are equal their hostnames
		* Warning!!! Destroy all machines before decreasing this parameters, or machines will leak
	* `network_prefix` 
	* `host_interface` is list of host interfaces
		* Vagrant will brige all machines on first avalible interface from list
	*   `node_script_path`  and `router_script_path` defines machine configuration scripts
		* they are local paths or URL
		* by default they are in `./config` folder
	* `config.vm.box` box for all machines
		*  see **About boxes** for details
	* `v.memory` memory per one machine

### About boxes

* Box is a packaged Vagrant evironment
	* it is like virtual machine snapshot
* Our main environment should work without Internet and we don't wont install same packages for all machines
* We can setup one machine and package it mamualy
	* I have made `box_machine` environment special for that
* Steps for making new box
	* cd to `box_machine` folder
	* modify `install_and_configure.sh` script
	* `./manage/recreate.sh`
		* it will destroy old `box_machine`
		* create pure
		* execute `install_and_configure.sh` in it
	* ssh if you need some manual confgurations
		* `./manage/ssh.sh box_machine` or `vagrant ssh box_machine`
	* `./manage/package_box.sh new_box_name` 
		* it will package current `box_machine` state to `./new_box_name.box` and add it to vagrant
* now you can set in main Vagrantfile `config.vm.box` to `new_box_name` and all new created machines will be based on this box
	* also you can share box via dropbox for example and set `config.vm.box_url`
	* if somebody get such Vagrantfile, Vagrant will automaticaly download this box from `config.vm.box_url`


