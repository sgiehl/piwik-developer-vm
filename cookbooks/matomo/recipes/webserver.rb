execute 'php8.0' do
  command 'add-apt-repository ppa:ondrej/php -y'
end

packages = %w(php8.0 php8.0-curl php8.0-dom php8.0-mbstring php8.0-gd php8.0-mysql php8.0-bz2 php8.0-zip php8.0-xdebug php8.0-redis php8.0-soap)

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
apache2_module 'php8.0' do
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

execute 'fix_apache_mod' do
  command 'sudo echo "LoadModule php_module /usr/lib/apache2/modules/libphp8.0.so" > /etc/apache2/mods-available/php8.0.load'
end

# php-fpm setup
php_fpm_pool 'matomo' do
  user  'vagrant'
  group 'vagrant'

  listen       '127.0.0.1:9000'
  listen_user  'vagrant'
  listen_group 'vagrant'
end