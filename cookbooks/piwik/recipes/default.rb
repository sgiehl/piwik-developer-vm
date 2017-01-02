packages = %w(mysql-server php5 php5-curl php5-gd php5-mysql)

packages.each do |pkg|
  apt_package pkg do
  end
end


composer_action = :install
piwik_source    = '/srv/piwik'
piwik_vendor    = "#{piwik_source}/vendor"

if File.directory?(piwik_vendor)
  composer_action = :update
end

include_recipe 'composer::self_update'

composer_project piwik_source do
  dev    true
  quiet  true
  action composer_action
end


apache_module 'php5' do
  enable false
end

apache_module 'proxy' do
end

apache_module 'proxy_fcgi' do
end


php_fpm_pool 'piwik' do
  user   'vagrant'
  group  'vagrant'

  listen       '127.0.0.1:9000'
  listen_user  'vagrant'
  listen_group 'vagrant'
end


web_app 'piwik' do
  server_name node['piwik']['server_name']
  docroot     "#{piwik_source}"
end

execute 'piwik_database' do
  command 'mysql -uroot -e \'CREATE DATABASE IF NOT EXISTS `piwik`\''
end

execute 'piwik_database_user' do
  command 'mysql -uroot -e \'GRANT ALL ON `piwik`.* TO "piwik"@"localhost" IDENTIFIED BY "piwik"\''
end
