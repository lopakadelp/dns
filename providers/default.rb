def load_current_resource
  new_resource.entry_name new_resource.name unless new_resource.entry_name
  new_resource.credentials node[:dns][:credentials] unless new_resource.credentials
  new_resource.dns_provider node[:dns][:provider] unless new_resource.dns_provider
end

action :create do

  # Use FQDN to generate domain.
  # Will assume domain name is the removal of the first section of FQDN.
  (subdomain, domain) = new_resource.entry_name.split('.', 2)

  # Verify domain is in account.
  zone = get_zone(domain)

  # Checking if DNS entry with value already exists.  Will skip if it already exists.
  # Based on known providers, will check for both subdomain and FQDN:
  # DME - record.name matches subdomain ie 'www'
  # AWS - record.name matches FQDN ending in 'www.domain.com.'
  if zone.records.detect do |record_entry|
    (record_entry.name == subdomain || record_entry.name =~ /^#{subdomain}\.#{domain}\.{0,1}$/) &&
    record_entry.value == new_resource.entry_value
  end
    Chef::Log.info "DNS entry already exists."

  else
    # Options for record creation.
    options = {:ttl => new_resource.ttl}
    options[:priority] = new_resource.priority if new_resource.priority

    case new_resource.dns_provider
    when "dnsmadeeasy"
      # Using Fog DNSMadeEasy API call to create record:
      # http://rubydoc.info/gems/fog/Fog/DNS/DNSMadeEasy/Real
      connection.create_record(domain, subdomain, new_resource.type.upcase, new_resource.entry_value, options)
    else
      zone.records.create(
        {
          :value => new_resource.entry_value,
          :name => new_resource.entry_name,
          :type => new_resource.type.upcase
        }.merge(options)
      )
    end

    Chef::Log.info "Created DNS entry: #{new_resource.entry_name} -> #{new_resource.entry_value}"
    new_resource.updated_by_last_action(true)
  end

end

action :update do

  # Use FQDN to generate domain.
  # Will assume domain name is the removal of the first section of FQDN.
  (subdomain, domain) = new_resource.entry_name.split('.', 2)

  # Verify domain is in account.
  zone = get_zone(domain)

  # Checking if DNS entry to be updated exists.
  # Based on known providers, will check for both subdomain and FQDN:
  # DME - record.name matches subdomain ie 'www'
  # AWS - record.name matches FQDN ending in 'www.domain.com.'
  matched_records = zone.records.find_all do |record_entry|
    (record_entry.name == subdomain || record_entry.name =~ /^#{subdomain}\.#{domain}\.{0,1}$/)
  end

  # Narrow search if current value is given.
  unless new_resource.entry_currentvalue.nil? || new_resource.entry_currentvalue.empty?
    case new_resource.dns_provider
    when "aws"
      # On Route53, the value is in an array.
      matched_records = matched_records.find_all do |record_entry|
        record_entry.value[0] == new_resource.entry_currentvalue
      end
    else
      matched_records = matched_records.find_all do |record_entry|
        record_entry.value == new_resource.entry_currentvalue
      end
    end
  end

  raise "No matching DNS records to update." if matched_records.empty?
  raise "Multiple DNS records discovered.  Provide current value of record to update." if matched_records.size > 1

  record = matched_records.first

  # If current value matches new value, should not continue and quietly exit.
  if record.value == new_resource.entry_value
    Chef::Log.info "Skipping attempt to set same current value in DNS entry: #{record.value}"
  else
    # Options for updating record.
    options = {:ttl => new_resource.ttl}
    options[:priority] = new_resource.priority if new_resource.priority

    case new_resource.dns_provider
    when "dnsmadeeasy"
      # From Fog doc:
      #
      # DNS Made Easy has no update record method but they plan to add it in the next update!
      # They sent a reponse suggesting, there going to internaly delete/create a new record when
      # we make update record call, so I've done the same here for now! If want to update a record,
      # it might be better to manually destroy and then create a new record

      # Using Fog DNSMadeEasy API call to delete record:
      # http://rubydoc.info/gems/fog/Fog/DNS/DNSMadeEasy/Real
      connection.delete_record(domain, record.id)
      connection.create_record(domain, subdomain, new_resource.type.upcase, new_resource.entry_value, options)
    when "aws"
      record.modify(
        {
          :value => new_resource.entry_value,
          :name => new_resource.entry_name,
          :type => new_resource.type.upcase
        }.merge(options)
      )
    else
      record.update(
        {
          :value => new_resource.entry_value,
          :name => new_resource.entry_name,
          :type => new_resource.type.upcase
        }.merge(options)
      )
    end

    Chef::Log.info "Updated DNS entry #{new_resource.entry_name} to #{new_resource.entry_value}"
    new_resource.updated_by_last_action(true)
  end
end

action :destroy do

  # Use FQDN to generate domain.
  # Will assume domain name is the removal of the first section of FQDN.
  (subdomain, domain) = new_resource.entry_name.split('.', 2)

  # Verify domain is in account.
  zone = get_zone(domain)

  # Create list of DNS records to delete.
  # Based on known providers, will check for both subdomain and FQDN:
  # DME - record.name matches subdomain ie 'www'
  # AWS - record.name matches FQDN ending in 'www.domain.com.'
  matched_records = zone.records.find_all do |record_entry|
    (record_entry.name == subdomain || record_entry.name =~ /^#{subdomain}\.#{domain}\.{0,1}$/)
  end

  # Narrow search if existing value is given.
  unless new_resource.entry_currentvalue.nil? || new_resource.entry_currentvalue.empty?
    Chef::Log.info "Searching specific value of #{new_resource.entry_currentvalue}"
    case new_resource.dns_provider
    when "aws"
      # On Route53, the value is in an array.
      matched_records = matched_records.find_all do |record_entry|
        record_entry.value[0] == new_resource.entry_currentvalue
      end
    else
      matched_records = matched_records.find_all do |record_entry|
        record_entry.value == new_resource.entry_currentvalue
      end
    end
  end

  if matched_records.empty?
    Chef::Log.info "No matching DNS records to delete (#{new_resource.entry_name})"
  else
    Chef::Log.info "#{matched_records.size} DNS record(s) found to delete"

    matched_records.each do |record|
      case new_resource.dns_provider
      when "dnsmadeeasy"
        # Using Fog DNSMadeEasy API call to delete record:
        # http://rubydoc.info/gems/fog/Fog/DNS/DNSMadeEasy/Real
        connection.delete_record(domain, record.id)
      else
        record.destroy
      end
    end

    Chef::Log.info "Deleted DNS entry(s) #{new_resource.entry_name}"
    new_resource.updated_by_last_action(true)
  end
end

def connection
  @con ||= CookbookDNS.fog(new_resource.credentials.merge(:provider => new_resource.dns_provider))
end

def get_zone(domain)
  # Verify domain is in account and return zone object.
  # Will check zone.id and zone.domain based on known providers:
  # DME - zone.id matches domain
  # AWS - zone.domain matches domain
  unless zone = connection.zones.detect do |zone_entry|
    zone_entry.id =~ /^#{domain}\.{0,1}$/ || zone_entry.domain =~ /^#{domain}\.{0,1}$/
  end
    raise "DOMAIN '#{domain}' NOT AVAILABLE IN ACCOUNT"
  end

  zone
end
