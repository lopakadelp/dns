include_recipe 'dns::fog'

dns 'Delete DNS entry' do
  dns_provider node[:dns][:provider]
  entry_name lazy { node[:dns][:entry][:name] }
  entry_currentvalue node[:dns][:entry][:currentvalue] if node[:dns][:entry][:currentvalue]
  action :destroy
end
