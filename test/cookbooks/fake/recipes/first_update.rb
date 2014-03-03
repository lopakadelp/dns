# Changes IP from 192.168.1.1 to 192.168.200.200

dns 'First Fake DNS update' do
  dns_provider 'aws'
  entry_name '101test.test.com'
  entry_value '192.168.200.200'
  entry_currentvalue '192.168.1.1'
  type 'A'
  ttl 60
  action :update
end
