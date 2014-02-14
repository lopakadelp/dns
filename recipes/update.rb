include_recipe 'dns::fog'

dns 'Update DNS entry' do
  record_id node[:dns][:entry][:record_id]
  entry_value node[:dns][:entry][:value]
  ttl node[:dns][:entry][:ttl]
  action :update
end
