def load_current_resource
  new_resource.entry_name new_resource.name unless new_resource.entry_name
  new_resource.credentials node[:dns][:credentials] unless new_resource.credentials
  new_resource.provider node[:dns][:provider] unless new_resource.provider
end

# actions below using Fog DNSMadeEasy API calls,
# http://rubydoc.info/gems/fog/Fog/DNS/DNSMadeEasy/Real

action :create do
  # Initiate connection and grab list of domains in account
  account_domains = connection.list_domains

  # Use FQDN to generate domain.
  # Will assume domain name is the removal of the first section of FQDN.
  (subdomain, domain) = new_resource.entry_name.split('.', 2)

  # Verify domain is in account
  raise "DOMAIN '#{domain}' NOT AVAILABLE IN ACCOUNT" unless account_domains[:body]["list"].include?(domain)

  # Check all A records if DNS entry already exists.
  all_records = connection.list_records(domain,{"type" => "A"})
  if all_records[:body].detect { | entry | entry['name'] == subdomain }
    raise "Entry '#{subdomain}.#{domain}' already exists"
  end

  options = Hash.new 
  options[:ttl] = new_resource.ttl ? new_resource.ttl : 1800

  connection.create_record(domain, subdomain, new_resource.type.upcase, new_resource.entry_value, options)

  Chef::Log.info "Created DNS entry: #{new_resource.entry_name} -> #{new_resource.entry_value}"

  new_resource.updated_by_last_action(true)

end

action :update do
  # Initiate connection and grab list of domains in account
  account_domains = connection.list_domains

  # Use FQDN to generate domain.
  # Will assume domain name is the removal of the first section of FQDN.
  (subdomain, domain) = new_resource.entry_name.split('.', 2)

  # Verify domain is in account
  raise "DOMAIN '#{domain}' NOT AVAILABLE IN ACCOUNT" unless account_domains[:body]["list"].include?(domain)

  # Check all A records if DNS entry already exists.
  all_records = connection.list_records(domain,{"type" => "A"})
  if all_records[:body].detect { | entry | entry['name'] == subdomain && entry['id'] == new_resource.record_id }
    raise "Entry matching id='#{entry['id']}' and entry='#{subdomain}' does not exist"
  end

  options = Hash.new 
  options[:ttl] = new_resource.ttl ? new_resource.ttl : 1800

  connection.create_record(domain, subdomain, new_resource.type.upcase, new_resource.entry_value, options)

  Chef::Log.info "Created DNS entry: #{new_resource.entry_name} -> #{new_resource.entry_value}"

  new_resource.updated_by_last_action(true)

end

action :destroy do
  # Initiate connection and grab list of domains in account
  account_domains = connection.list_domains

  # Verify domain is in account
  raise "DOMAIN '#{new_resource.domain}' NOT AVAILABLE IN ACCOUNT" unless account_domains[:body]["list"].include?(new_resource.domain)

  # Check all A records if record_id DNS entry exists.
  all_records = connection.list_records(domain,{"type" => "A"})
  if all_records[:body].detect { | entry | entry['id'] == new_resource.record_id }
    raise "Entry #{new_resource.record_id} does not exists - cannot delete"
  end

  connection.delete_record(new_resource.domain, new_resource.record_id)

  Chef::Log.info "Deleted DNS entry: #{new_resource.record_id}"

end

def connection
  @con ||= CookbookDNS.fog(new_resource.credentials.merge(:provider => new_resource.provider)
  )
end
