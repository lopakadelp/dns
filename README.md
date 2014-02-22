# DNS

Create DNS records on a variety of providers and
create DNS records for your nodes automatically.

## Recipes

* `default` create DNS entry for current node
* `delete` deletes DNS entry
* `update` updates DNS entry
* `fqdn` updates node fqdn and hosts file
* `chef-client` updates the chef-client config resource to include original node name

## LWRP

* actions: `:create`, `:destroy`, `:update`

### Example

```ruby
dns 'www.example.org' do
  dns_provider 'some_dns_provider'
  credentials :some_cloud_token => '[TOKEN]', :some_cloud_key => '[KEY]'
  entry_value '127.0.2.2'
  type 'A'
  ttl 1800
end
```

## Attributes

* `node[:dns][:provider]` - dns provider name (must be fog compatible)
* `node[:dns][:domain]` - domain of the record
* `node[:dns][:credentials]` - hash of connection credentials (must be fog compatible)
* `node[:dns][:disable]` - disable creation of node dns record
* `node[:dns][:entry][:name]` - dns entry name
* `node[:dns][:entry][:type]` - dns entry type
* `node[:dns][:entry][:value]` - dns entry value
* `node[:dns][:entry][:currentvalue]` - dns entry value of record to update or delete
* `node[:dns][:chef_client_config]` - automatically include `dns::chef-client` recipe

# Infos
* Repository: https://github.com/hw-cookbooks/dns
* IRC: Freenode @ #heavywater
* Cookbook: http://ckbk.it/dns
