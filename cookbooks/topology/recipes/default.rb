attr = node['topology']

scripts_dir   = attr['output_dir']
scripts_owner = 'root'
scripts_group = 'root'
scripts_mode  = '0777'

directory scripts_dir do
  owner scripts_owner
  group scripts_group
  mode  scripts_mode
  recursive true
  action :create
end

template "#{scripts_dir}/mesh.sh" do
  source 'mesh.erb'
  owner scripts_owner
  group scripts_group
  mode  scripts_mode
  variables({
     :vlan_up       => attr['vlan_up'],
     :interface     => attr['interface'],
     :routers_count => attr['routers_count'],
     :router_num    => attr['router_num'],
  })
end

template "#{scripts_dir}/ring.sh" do
  source 'ring.erb'
  owner scripts_owner
  group scripts_group
  mode  scripts_mode
  variables({
     :vlan_up       => attr['vlan_up'],
     :interface     => attr['interface'],
     :routers_count => attr['routers_count'],
     :router_num    => attr['router_num'],
  })
end

template "#{scripts_dir}/none.sh" do
  source 'none.erb'
  owner scripts_owner
  group scripts_group
  mode  scripts_mode
  variables({
     :vlan_up       => attr['vlan_up'],
     :interface     => attr['interface'],
     :routers_count => attr['routers_count'],
     :router_num    => attr['router_num'],
  })
end

