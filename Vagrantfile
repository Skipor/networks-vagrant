# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = '2'

Vagrant.require_version '>= 1.8'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  #check chef version in box
  if not Vagrant.has_plugin?('vagrant-omnibus') 
    raise 'Error: no omnibus plugin! Install manualy or run ./install_plugins.sh'
  end
  config.omnibus.chef_version = '11.6.0'

  #packages will be dowloaded once on machines
  #apt-get error if use machine same time
  if Vagrant.has_plugin?("vagrant-cachier") 
    config.cache.scope = :box
  end

  
  ############################
  #BEGIN OF CUSTOM CONFIGURATION
  ############################
  
  config.vm.provider 'virtualbox' do |v|
    v.memory = 256
    v.linked_clone = true
  end
  # box from official repo. pure ubuntu
  # config.vm.box = "ubuntu/trusty64"
  
  #example of local box added via "vagrant box add"
  #config.vm.box = "netlab-v1"

  #example custom box from internet
  #config.vm.box = "https://dl.dropboxusercontent.com/u/102236368/netlab-v1.box"
  
  #custom box from internet, simply stored in dropbox
  #lab2 box
  #config.vm.box = 'netlab-v2'
  #config.vm.box_url = 'https://dl.dropboxusercontent.com/u/102236368/netlab-v2.box'

  #lab3 box
  config.vm.box = 'netlab-v4'
  config.vm.box_url = 'https://dl.dropboxusercontent.com/u/102236368/netlab-v4.box'


  # paths can be gist or URL or local files
  # example gist paths
  #node_script_path   = 'https://gist.githubusercontent.com/Skipor/0744cf2f5b58a42f9d0e/raw/6bd122cae769c5e04b7b86fbbfba32f869c379b7/install_client.sh'
  #router_script_path = 'https://gist.github.com/Skipor/0744cf2f5b58a42f9d0e/raw/6bd122cae769c5e04b7b86fbbfba32f869c379b7/install_router.sh'
  
  # local paths
  node_script_path   = 'config/install_client.sh'
  router_script_path = 'config/install_router.sh' 

  host_interface = [  #priority list of interfaces to brige on host machine 
    'en0: Wi-Fi (AirPort)', 
    'en0',
    'eth0', 
    'wlan0'
  ] 
  network_prefix = '192.168'


  # WARNING!!! Destroy machines before change this parametrs to preasume machines LEAK.
  # machines that exists and will not exists in new Vagrantfile will LEAK, and can be running in background. 
  # But you still can delete them from virtualbox
  topology_script_dir = '/topology'
  #topology = "none"
  topology = "ring"
  #topology = "mesh"

  routers_count = 4
  nodes_count = 1

  ############################
  #END OF CUSTOM CONFIGURATION
  ############################
  
  router_range = (1..routers_count)
  node_range = (2..(nodes_count + 1)) # WARNING low bound should be 2
  guest_brige = 'eth1' #eth0 id NAT interface for vagrant usage. Seems all vms have same ip on it

  #configure machines in cycle. one router and nore_range nodes for every router in router_range
  router_range.each do |router_num|
    #config router vm
    router_name = "router-#{router_num}"
    config.vm.define router_name do |router|
      router.vm.hostname = router_name

    router.vm.network 'public_network', 
      ip: "#{network_prefix}.1.#{router_num}0", 
      bridge: host_interface#, 
      #auto_config: false
      
     #config.vm.provision 'shell', inline: 'cp -f /vagrant/config/daemons /etc/quagga/daemons'

      router.vm.provision 'shell',
        inline: "echo hello from #{router_name}"

      interface_list = ''
      router_range.each do |other_router_num|
        router_pair  = [router_num, other_router_num]
        interface_list << "#{router_pair.min}#{router_pair.max} "
      end
      router.vm.provision 'local', run: 'always', type: 'shell' do |s| 
        s.path = router_script_path
        s.args = [guest_brige, "#{router_num}", "#{routers_count}", interface_list]
      end

      router.vm.provision 'topology_scripts', run: 'once', type: 'chef_solo' do |chef|
        chef.json = {
            'topology' => {
              'vlan_up' => '/vagrant/config/vlan_up.sh',
              'router_num' => router_num,
              'routers_count' => routers_count,
              'interface' => guest_brige,
              'output_dir' => topology_script_dir,
            }
          }
        chef.add_recipe 'topology'
        chef.node_name = router_name
      end

      router.vm.provision 'topology', run: 'always', type: 'shell' do |s| 
        s.inline = "bash #{topology_script_dir}/#{topology}.sh"
      end

      router.vm.provision 'local', run: 'once', type: :shell do |s| 
        s.path = "./config/install_router.sh"
        s.args = [guest_brige, "#{router_num}", "#{routers_count}", interface_list]
      end

    end #router vm

    # this router nodes vms cycle
    node_range.each do |node_num|

      #config node vm
      node_name = "node-#{router_num}-#{node_num}"
      config.vm.define node_name do |node|
        node.vm.hostname = node_name
        node.vm.network 'public_network', 
          ip: "#{network_prefix}.#{router_num}0.#{node_num}", 
          bridge: host_interface#, 
          #auto_config: false

        node.vm.provision 'shell',
          inline: "echo hello from #{node_name}"
        node.vm.provision 'local', run: 'always', type: 'shell' do |s| 
          s.path = node_script_path
          s.args = [guest_brige, "#{node_num}", "#{router_num}"]
        end


      end #node vm
    end #node cycle

  end #router cycle

end #config

