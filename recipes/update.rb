include_recipe 'dns::fog'

dns 'Update DNS entry' do
  entry_name lazy{ node[:dns][:entry][:name] }
  entry_value node[:dns][:entry][:value]
  entry_oldvalue node[:dns][:entry][:oldvalue]
  type node[:dns][:entry][:type]
  ttl node[:dns][:entry][:ttl]
  action :update
end
