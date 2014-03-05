def load_current_resource
  new_resource.entry_name new_resource.name unless new_resource.entry_name
  new_resource.credentials node[:dns][:credentials] unless new_resource.credentials
  new_resource.dns_provider node[:dns][:provider] unless new_resource.dns_provider
end

action :create do

  require "rest_client"
  require "json"

  subdomain = new_resource.entry_name
  domain = new_resource.domain

  api_url = "https://api.dnsmadeeasy.com/V2.0"
  resource = RestClient::Resource.new(api_url)

  # Determine if domain/zone is in the account.
  zones = JSON.parse(resource["dns/managed"].get(auth_headers))
  zone = zones["data"].detect do |z|
    z["name"] == domain
  end
  raise "Domain '#{domain}' not found. No changes made." unless zone

  domain_id = zone["id"];

  # Check if entry exists to update otherwise create.
  records = JSON.parse(resource["dns/managed/#{domain_id}/records"].get(auth_headers))
  record = records["data"].detect do |r|
    r["name"] == subdomain
  end

  args = {
    "name" => "#{subdomain}",
    "type" => "#{new_resource.type.upcase}",
    "value" => "#{new_resource.entry_value}",
    "ttl" => new_resource.ttl
  }

  # Record exists - update.
  if(record)
    dns_id = record["id"]
    args["id"] = dns_id

    # Compare current values in record to determine if updating is needed.
    diff = args.keys.find_all do |k|
      record[k] != args[k]
    end
    if (diff.empty?)
      Chef::Log.info "No changes to be made."
    else
      resource["dns/managed/#{domain_id}/records/#{dns_id}"].put(JSON.generate(args), auth_headers)
      Chef::Log.info "Updated DNS entry: #{subdomain} -> #{diff.map{|k| "#{k}:#{args[k]}"}.join(', ')}"
      new_resource.updated_by_last_action(true)
    end
  # Record does not exist - create.
  else
    resource["dns/managed/#{domain_id}/records"].post(JSON.generate(args), auth_headers)
    Chef::Log.info "Created DNS entry: #{subdomain} -> #{new_resource.entry_value}"
    new_resource.updated_by_last_action(true)
  end
end

action :destroy do
  require "rest_client"
  require "json"

  subdomain = new_resource.entry_name
  domain = new_resource.domain

  api_url = "https://api.dnsmadeeasy.com/V2.0"
  resource = RestClient::Resource.new(api_url)

  # Determine if domain/zone is in the account.
  zones = JSON.parse(resource["dns/managed"].get(auth_headers))
  zone = zones["data"].detect do |z|
    z["name"] == domain
  end
  raise "Domain '#{domain}' not found. No changes made." unless zone

  domain_id = zone["id"];

  # Check if entry exists.
  records = JSON.parse(resource["dns/managed/#{domain_id}/records"].get(auth_headers))
  record = records["data"].detect do |r|
    r["name"] == subdomain
  end

  if(record)
    resource["dns/managed/#{domain_id}/records/#{record["id"]}"].delete(auth_headers)
    Chef::Log.info "Destroyed DNS entry: #{new_resource.entry_name}"
    new_resource.updated_by_last_action(true)
  else
    Chef::Log.info "DNS entry '#{new_resource.entry_name}' does not exist. No changes made."
  end
end

def auth_headers
  # Generate authentication headers used by API.
  require "time"

  api_key = new_resource.credentials["dnsmadeeasy_api_key"]
  secret_key = new_resource.credentials["dnsmadeeasy_secret_key"]

  request_time = Time.now.httpdate
  hmac = OpenSSL::HMAC.hexdigest('sha1',secret_key ,request_time)

  {
    :"x-dnsme-apiKey" => "#{api_key}",
    :"x-dnsme-hmac" => "#{hmac}",
    :"x-dnsme-requestDate" => "#{request_time}"
  }
end