default[:dns][:provider] = node[:cloud] ? node[:cloud][:provider] : nil
default[:dns][:credentials] = {}
default[:dns][:disable] = !node[:cloud]
default[:dns][:entry][:name] = node[:fqdn]
default[:dns][:entry][:type] = 'A'
default[:dns][:entry][:value] = node[:ipaddress]
default[:dns][:entry][:ttl] = 60
default[:dns][:entry][:record_id] = ""
default[:dns][:chef_client_config] = false
