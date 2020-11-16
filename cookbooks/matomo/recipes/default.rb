# package setup
include_recipe 'apt'
include_recipe 'matomo::database'
include_recipe 'matomo::webserver'

unless node['matomo']['vm_type'] == 'minimal'
  include_recipe 'redisio'
  include_recipe 'redisio::enable'

  ## stuff required to run UI tests locally
  include_recipe 'matomo::uitests'

  ## stuff required to build GeoIP2 databases
  include_recipe 'matomo::geoip'
end


packages = %w(git curl python2.7)

unless node['matomo']['vm_type'] == 'minimal'
  packages += %w(git-lfs openjdk-8-jre woff2)

  packagecloud_repo 'github/git-lfs' do
    type 'deb'
  end
end

packages.each do |pkg|
  package pkg do
    action :install
  end
end

# link python executable
execute 'python_link' do
  command '[ -L /usr/bin/python ] || ln -s /usr/bin/python3 /usr/bin/python'
end

# composer setup
include_recipe 'composer::self_update'

composer_project node['matomo']['docroot'] do
  dev    true
  quiet  true
  action :install
end