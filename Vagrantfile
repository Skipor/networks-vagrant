# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = '2'

Vagrant.require_version '>= 1.5.4'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.omnibus.chef_version = '11.6.0'

  # box from official repo. pure ubuntu
  # config.vm.box = "ubuntu/trusty64"
  
  #example of local box added via "vagrant box add"
  #config.vm.box = "netlab-v1"

  #example custom box from internet
  #config.vm.box = "https://dl.dropboxusercontent.com/u/102236368/netlab-v1.box"
  
  #custom box from internet, simply stored in dropbox
  config.vm.box = 'netlab-v1'
  config.vm.box_url = 'https://dl.dropboxusercontent.com/u/102236368/netlab-v1.box'


  config.vm.provider 'virtualbox' do |v|
    v.memory = 256
  end

  # paths can be gist or URL or local files
  # example gist paths
  #node_script_path   = 'https://gist.github.com/Skipor/0744cf2f5b58a42f9d0e#file-install_client-sh'
  #router_script_path = 'https://gist.github.com/Skipor/0744cf2f5b58a42f9d0e#file-install_router-sh' 
  
  # local paths
  node_script_path   = 'install_client.sh'
  router_script_path = 'install_router-sh' 

  # WARNING!!! Destroy machines before change this parametrs to preasume machines LEAK.
  # machines that exists and will not exists in new Vagrantfile will LEAK, and can be running in background. 
  # But you still can delete them from virtualbox
  router_range = (1..3)
  node_range = (1..1)


  
  #configure machines in cycle. one router and nore_range nodes for every router in router_range
  routers_count = router_range.count
  router_range.each do |router_num|

    #config router vm
    router_name = "router-#{router_num}"
    config.vm.define router_name do |router|
      router.vm.hostname = router_name
      router.vm.provision 'shell',
        inline: "echo hello from #{router_name}"

      router.vm.provision 'shell' do |s| 
        s.path = router_script_path
        s.args = ['eth0', "#{router_num}", "#{routers_count}"]
      end

    end #router vm

    # this router nodes vms cycle
    node_range.each do |node_num|

      #config node vm
      node_name = "node-#{router_num}-#{node_num}"
      config.vm.define node_name do |node|
        node.vm.hostname = router_name
        node.vm.provision 'shell',
          inline: "echo hello from #{node_name}"
        node.vm.provision 'shell' do |s| 
          s.path = node_script_path
          s.args = ['eth0', "#{node_num}", "#{router_num}"]
        end
      end #node vm
    end #node cycle

  end #router cycle

end #config

