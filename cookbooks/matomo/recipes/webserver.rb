packages = %w(php7.2 php7.2-curl php7.2-mbstring php7.2-gd php7.2-mysql php7.2-bz2 php7.2-zip php7.2-xdebug php7.2-redis php7.2-soap)

packages.each do |pkg|
  package pkg do
    action :install
  end
end

# disable xdebug by default
execute 'disable_xdebug' do
  command 'sudo phpdismod xdebug'
end

# apache setup
apache2_module 'php7.2' do
  action :disable
end

# application setup
apache2_install 'default'

service 'apache2' do
  service_name lazy { apache_platform_service_name }
  supports restart: true, status: true, reload: true
  action [:start, :enable]
end

apache2_module 'proxy'
apache2_module 'proxy_fcgi'

template 'matomo' do
  source 'matomo.conf.erb'
  path "#{apache_dir}/sites-available/matomo.conf"
  variables(
    server_name: node['matomo']['server_name'],
    docroot: node['matomo']['docroot']
  )
end

apache2_site '000-default' do
  action :disable
end

apache2_site 'matomo' do
  action :enable
end

# php-fpm setup
php_fpm_pool 'matomo' do
  user  'vagrant'
  group 'vagrant'

  listen       '127.0.0.1:9000'
  listen_user  'vagrant'
  listen_group 'vagrant'
end