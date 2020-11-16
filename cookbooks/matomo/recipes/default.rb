# package setup
include_recipe 'apt'

packages = %w(git curl mysql-server python2.7 php7.2 php7.2-curl php7.2-mbstring php7.2-gd php7.2-mysql php7.2-bz2 php7.2-zip php7.2-xdebug)

unless node['matomo']['vm_type'] == 'minimal'
  packages += %w(git-lfs openjdk-8-jre php7.2-redis php7.2-soap woff2)

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

unless node['matomo']['vm_type'] == 'minimal'
  include_recipe "chrome"
  include_recipe "nodejs::nodejs_from_binary"

  npm_package 'screenshot-testing' do
    path '/srv/matomo/tests/lib/screenshot-testing'
    json true
    user 'vagrant'
  end

  # imagemagick setup
  include_recipe 'imagemagick::default'
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

# disable xdebug by default
execute 'disable_xdebug' do
  command 'sudo phpdismod xdebug'
end

# mysql setup
# HACK: ensure mysql is started in docker after installation
execute 'mysql_start' do # ~FC004
  command '/etc/init.d/mysql start || true'
end

# php-fpm setup
php_fpm_pool 'matomo' do
  user  'vagrant'
  group 'vagrant'

  listen       '127.0.0.1:9000'
  listen_user  'vagrant'
  listen_group 'vagrant'
end

# composer setup
include_recipe 'composer::self_update'

composer_project node['matomo']['docroot'] do
  dev    true
  quiet  true
  action :install
end

# redis setup
unless node['matomo']['vm_type'] == 'minimal'
  include_recipe 'redisio'
  include_recipe 'redisio::enable'
end

execute 'copy_fonts' do
  command '[ -d /home/vagrant/.fonts ] || mkdir /home/vagrant/.fonts; cp -f /srv/matomo/tests/travis/fonts/* /home/vagrant/.fonts'
  user  'vagrant'
  group 'vagrant'
end

execute 'matomo_database' do
  command <<-DBSQL
  mysql -uroot -e '
      CREATE DATABASE IF NOT EXISTS \`#{node['matomo']['mysql_database']}\`
  '
  DBSQL
end

execute 'matomo_database_settings' do
  command <<-DBSQL
  mysql -uroot -e '
      SET @@GLOBAL.innodb_flush_log_at_trx_commit = 2;
      SET @@GLOBAL.max_allowed_packet = 67108864;
  '
  DBSQL
end

execute 'matomo_database_user' do
  command <<-USERSQL
  mysql -uroot -e '
      GRANT ALL ON *.*
      TO "#{node['matomo']['mysql_username']}"@"localhost"
      IDENTIFIED BY "#{node['matomo']['mysql_password']}";
  '
  USERSQL
end

unless node['matomo']['vm_type'] == 'minimal'
  execute 'matomo_tests_database' do
    command <<-DBSQL
    mysql -uroot -e '
        CREATE DATABASE IF NOT EXISTS \`matomo_tests\`
    '
    DBSQL
  end

  # install some packages required to build GeoIP2 database files (mmdb)
  # required to run /matomo/tests/lib/geoip-files/writeTestFiles.pl
  include_recipe 'build-essential::default'
  build_essential 'install compilation tools' # required to compile modules

  include_recipe 'perl::default'
  cpan_module 'MaxMind::DB::Writer::Serializer'
  cpan_module 'File::Slurper'
  cpan_module 'Cpanel::JSON::XS'
end