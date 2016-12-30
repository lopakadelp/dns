node.override['build_essential']['compiletime'] = true
include_recipe 'build-essential'

# XML dependencies required by nokogiri (for fog)
node.override['xml']['compiletime'] = true
include_recipe 'xml'
include_recipe 'fog_gem::default'
include_recipe 'fog_gem::chefgem'
# TODO: Remove this once the gem_hell cookbook is ready to roll
# chef_gem 'fog' do
#   version '1.20.0'
#   action :install
# end
