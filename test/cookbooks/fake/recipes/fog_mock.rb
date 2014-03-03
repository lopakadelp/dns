include_recipe 'dns::fog'

require 'fog'

# Turn on Fog mocking
if node[:dns][:mock]
  Fog.mock!
end
