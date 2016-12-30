name 'dns'
maintainer 'Chris Roberts'
maintainer_email 'chrisroberts.code@gmail.com'
license 'Apache 2.0'
description 'Create DNS entries for nodes'
version '0.1.5'
issues_url 'https://github.com/rightscale-cookbooks-contrib/dns/issues'
source_url 'https://github.com/rightscale-cookbooks-contrib/dns'
chef_version '>= 12.0' if respond_to?(:chef_version)

depends 'hosts_file', '~> 0.2.2'
depends 'fog_gem'
depends 'build-essential', '>= 1.1.0' # set minimum so we get compile time support
depends 'xml', '~> 1.2.0'
depends 'chef-client'
