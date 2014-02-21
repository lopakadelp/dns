include_recipe 'dns::fog'

dns 'Update DNS entry' do
  dns_provider node[:dns][:provider]
  entry_name lazy { node[:dns][:entry][:name] }
  entry_value node[:dns][:entry][:value]
  entry_currentvalue node[:dns][:entry][:currentvalue]
  type node[:dns][:entry][:type]
  ttl node[:dns][:entry][:ttl]
  action :update
end
