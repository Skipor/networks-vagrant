# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = '2'

Vagrant.require_version '>= 1.5.4'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.omnibus.chef_version = '11.6.0'

  config.vm.box = "ubuntu/trusty64"
  config.vm.provider 'virtualbox' do |v|
    v.memory = 256
  end

  # group_num = 4
  # if ENV['GROUP_NUM']
  #   group_num = ENV['GROUP_NUM'].to_i
  #   puts "Group num: #{group_num}"
  # else 
  #   puts "Warning!!! Using default gropu_num: #{group_num}"
  #   puts "Use export to set node goup: 'export GROUP_NUM=5'"
  # end

  # node_num = 4
  # if ENV['NODE_NUM']
  #   node_num = ENV['NODE_NUM'].to_i
  #   puts "Group num: #{node_num}"
  # else 
  #   puts "Warning!!! Using default gropu_num: #{group_num}"
  #   puts "Use export to set node goup: 'export GROUP_NUM=5'"
  # end
  #
  #


  config.vm.define "node" do |node|
    node.vm.provision "shell",
      inline: "echo hello from node"
  end

  # paths can be gist or URL or local files
  # example gist paths
  #node_script_path   = "https://gist.github.com/Skipor/0744cf2f5b58a42f9d0e#file-install_client-sh" 
  #router_script_path = "https://gist.github.com/Skipor/0744cf2f5b58a42f9d0e#file-install_router-sh" 
  
  # local paths
  #node_script_path   = "install_client.sh" 
  #router_script_path = "install_router-sh" 

  # WARNING!!! Destroy machines before change this parametrs to preasume machines LEAK.
  # machines that exists and will not exists in new Vagrantfile will LEAK, and can be running in background. 
  # But you still can delete them from virtualbox
  #group_range = (1..3)
  #node_range = (1..3)
  
  #group_range.each do |group_num|
  #  router_name = "router-#{group_num}"
  #  config.vm.define router_name do |router|
  #      node.vm.provision "shell" do |s| 
  #        s.path = router_script_path
  #        s.args = ["#{node_num}", "#{group_num}", "en0"]
  #      end
  #  end

  #  node_range.each do |node_num|
  #    config.vm.define "node-#{i}" do |node|
  #      node.vm.provision "shell",
  #        inline: "echo hello from node #{i}"
  #      node.vm.provision "shell" do |s| 
  #        s.path = node_script_path
  #        s.args = ["#{node_num}", "#{group_num}", "en0"]
  #      end
  #    end
  #  end
  #end

end

