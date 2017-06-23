# package setup
include_recipe 'apt'

packages = %w(git mysql-server php5 php5-curl php5-gd php5-mysql php5-xdebug)

unless 'minimal' == node['piwik']['type']
  packages += %w(git-lfs openjdk-7-jre php5-redis)

  packagecloud_repo 'github/git-lfs' do
    type 'deb'
  end
end

packages.each do |pkg|
  package pkg do
  end
end

# composer setup
include_recipe 'composer::self_update'

composer_project node['piwik']['docroot'] do
  dev    true
  quiet  true
  action :install
end

composer_project node['piwik']['device_detector'] do
  dev    true
  quiet  true
  action :install
  only_if { File.directory?(node['piwik']['device_detector']) }
end

unless 'minimal' == node['piwik']['type']
  # phantomjs setup
  include_recipe 'phantomjs2::default'
  # imagemagick setup
  include_recipe 'imagemagick::default'
end

# apache setup
apache_module 'php5' do
  enable false
end

apache_module 'proxy' do
end

apache_module 'proxy_fcgi' do
end

# mysql setup
# HACK: ensure mysql is started in docker after installation
execute 'mysql_start' do # ~FC004
  command '/etc/init.d/mysql start || true'
end

# php-fpm setup
php_fpm_pool 'piwik' do
  user   'vagrant'
  group  'vagrant'

  listen       '127.0.0.1:9000'
  listen_user  'vagrant'
  listen_group 'vagrant'
end

# redis setup
unless 'minimal' == node['piwik']['type']
  include_recipe 'redisio'
  include_recipe 'redisio::enable'
end

# application setup
web_app 'piwik' do
  server_name node['piwik']['server_name']
  docroot     node['piwik']['docroot']
end

execute 'piwik_database' do
  command 'mysql -uroot -e \'CREATE DATABASE IF NOT EXISTS `piwik`\''
end

execute 'piwik_database_user' do
  command <<-USERSQL
  mysql -uroot -e '
      GRANT ALL ON `piwik`.* TO "piwik"@"localhost" IDENTIFIED BY "piwik";
  '
  USERSQL
end

unless 'minimal' == node['piwik']['type']
  execute 'piwik_tests_database' do
    command 'mysql -uroot -e \'CREATE DATABASE IF NOT EXISTS `piwik_tests`\''
  end

  execute 'piwik_tests_database_user' do
    command <<-USERSQL
    mysql -uroot -e '
        GRANT ALL ON `piwik_tests`.* TO "piwik"@"localhost" IDENTIFIED BY "piwik";
    '
    USERSQL
  end
end
