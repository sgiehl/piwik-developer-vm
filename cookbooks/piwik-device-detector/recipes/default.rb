# composer setup
include_recipe 'composer::self_update'

composer_project node['piwik-device-detector']['docroot'] do
  dev    true
  quiet  true
  action :install
end
