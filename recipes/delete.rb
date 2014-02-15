include_recipe 'dns::fog'

dns 'Delete DNS entry' do
  entry_name lazy{ node[:dns][:entry][:name] }
  entry_value node[:dns][:entry][:value]
  action :destroy
end
