node.set[:build_essential][:compiletime] = true
include_recipe 'build-essential'

# Dependencies required by nokogiri (for fog)
nokogiri_dependencies = value_for_platform_family(
  ["centos", "rhel"] => ["libxslt-devel", "libxml2-devel"],
  "debian" => ["libxslt-dev", "libxml2-dev"]
  )
nokogiri_dependencies.each do |pkg|
  c_pkg = package(pkg)
  c_pkg.run_action(:install)
end

# TODO: Remove this once the gem_hell cookbook is ready to roll
chef_gem "fog" do
  version '1.20.0'
  action :install
end
