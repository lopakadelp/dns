def load_current_resource
  new_resource.entry_name new_resource.name unless new_resource.entry_name
  new_resource.credentials node[:dns][:credentials] unless new_resource.credentials
  new_resource.provider node[:dns][:provider] unless new_resource.provider
end

action :create do

  # Use FQDN to generate domain.
  # Will assume domain name is the removal of the first section of FQDN.
  (subdomain, domain) = new_resource.entry_name.split('.', 2)

  # Verify domain is in account
  # DME - zone.id matches domain
  # AWS - zone.domain matches domain
  unless zone = connection.zones.detect { | zone_entry | zone_entry.id =~ /^#{domain}\.{0,1}$/ || zone_entry.domain =~ /^#{domain}\.{0,1}$/ }
    raise "DOMAIN '#{domain}' NOT AVAILABLE IN ACCOUNT"
  end

  # Check records if DNS entry already exists.
  # DME record.name matches subdomain ie 'www'
  # AWS record.name matches FQDN ending in 'www.domain.com.'
  if record = zone.records.detect { | record_entry | record_entry.name == subdomain || record_entry.name =~ /^#{subdomain}\.#{domain}\.{0,1}$/ } 
    raise "Entry '#{subdomain}.#{domain}' already exists"
  end

  # Create hash with options for creating the record.
  options = Hash.new
  options[:ttl] = new_resource.ttl ? new_resource.ttl : 1800
  options[:priority] = new_resource.priority if new_resource.priority

  case new_resource.provider
  when "dnsmadeeasy"
    # Using Fog DNSMadeEasy API call:
    # http://rubydoc.info/gems/fog/Fog/DNS/DNSMadeEasy/Real
    connection.create_record(domain, subdomain, new_resource.type.upcase, new_resource.entry_value, options)
  else
    zone.records.create({:value => new_resource.entry_value,
                        :name => new_resource.entry_name,
                        :type => new_resource.type.upcase}.merge(options)
                       )
  end

  Chef::Log.info "Created DNS entry: #{new_resource.entry_name} -> #{new_resource.entry_value}"
  new_resource.updated_by_last_action(true)
end

action :update do
  if new_resource.provider == "dnsmadeeasy"
    # From Fog doc:
    #
    # DNS Made Easy has no update record method but they plan to add it in the next update!
    # They sent a reponse suggesting, there going to internaly delete/create a new record when
    # we make update record call, so I've done the same here for now! If want to update a record,
    # it might be better to manually destroy and then create a new record

    action_destroy
    action_create

  else
    # update action not yet available for other DNS providers
    false
  end
end

action :destroy do
  # Use FQDN to generate domain.
  # Will assume domain name is the removal of the first section of FQDN.
  (subdomain, domain) = new_resource.entry_name.split('.', 2)

  # Verify domain is in account
  # DME - zone.id matches domain
  # AWS - zone.domain matches domain
  unless zone = connection.zones.detect { | zone_entry | zone_entry.id =~ /^#{domain}\.{0,1}$/ || zone_entry.domain =~ /^#{domain}\.{0,1}$/ }
    raise "DOMAIN '#{domain}' NOT AVAILABLE IN ACCOUNT"
  end

  # Check records if DNS entry already exists.
  # DME record.name matches subdomain ie 'www'
  # AWS record.name matches FQDN ending in 'www.domain.com.'
  unless record = zone.records.detect { | record_entry | record_entry.name == subdomain || record_entry.name =~ /^#{subdomain}\.#{domain}\.{0,1}$/ } 
    raise "Entry '#{new_resource.entry_name}' does not exist"
  end

  case new_resource.provider
  when "dnsmadeeasy"
    connection.delete_record(domain, record.id)
  else
    record.destroy
  end

  Chef::Log.info "Deleted DNS entry #{new_resource.entry_name}"
  new_resource.updated_by_last_action(true)
end

def connection
  @con ||= CookbookDNS.fog(new_resource.credentials.merge(:provider => new_resource.provider))
end
