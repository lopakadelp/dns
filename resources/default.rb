actions :create, :destroy, :update
default_action :create

attribute :entry_name, :kind_of => String
attribute :entry_value, :kind_of => String, :required => true
attribute :entry_oldvalue, :kind_of => String
attribute :credentials, :kind_of => Hash
attribute :dns_provider, :kind_of => String
attribute :domain, :kind_of => String
attribute :type, :kind_of => String, :required => true, :default => 'A'
attribute :ttl, :kind_of => Numeric
attribute :priority, :kind_of => Numeric
