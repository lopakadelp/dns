include_recipe 'dns::fog'

require 'rubygems'
require 'fog'

dns = Fog::DNS.new({
  :provider     => 'aws',
  :aws_access_key_id => "AWS_KEY",
  :aws_secret_access_key => "AWS_SECRET"
})

dns.zones.create(
  :domain => 'test.com',
  :email  => 'admin@example.com'
)
