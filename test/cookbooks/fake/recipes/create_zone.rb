include_recipe 'dns::fog'

require 'rubygems'
require 'fog'

dns = Fog::DNS.new({
  :provider     => 'aws',
  :zerigo_email => "AWS_KEY",
  :zerigo_token => "AWS_SECRET"
})

dns.zones.create(
  :domain => 'test.rightscale.com',
  :email  => 'admin@example.com'
)
