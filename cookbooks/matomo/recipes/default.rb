# application setup
web_app 'matomo' do
  server_name node['matomo']['server_name']
  docroot     node['matomo']['docroot']
end

# package setup
include_recipe 'apt'

packages = %w(git curl mysql-server python2.7 php7.2 php7.2-mbstring php7.2-gd php7.2-mysql php7.2-bz2 php7.2-zip php7.2-xdebug)

unless node['matomo']['vm_type'] == 'minimal'
  packages += %w(git-lfs openjdk-8-jre php-redis php-soap)

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
  command '[ -L /usr/bin/python ] || ln -s /usr/bin/python2.7 /usr/bin/python'
end

unless node['matomo']['vm_type'] == 'minimal'
  include_recipe "chrome"
  include_recipe "nodejs"
  include_recipe "nvm"

  # install node.js v0.10.5
  nvm_install '8'  do
    from_source false
    alias_as_default true
    action :create
  end
  #execute 'npm_install' do
  #  command 'cat package.json | sed -n -e \'/dependencies/,/\}/{ /dependencies/d; /\}/d; p; }\' | sed -e \'s/,//\' | awk \'{ print substr($1, 2, length($1)-3) "@" substr($2, 2, length($2)-2) }\' | xargs -n 1 npm install -g'
  #  cwd '/srv/matomo/tests/lib/screenshot-testing'
  #  user  'root'
  #end
  # imagemagick setup
  include_recipe 'imagemagick::default'
end

# apache setup
apache_module 'php7.2' do
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
php_fpm_pool 'matomo' do
  user  'vagrant'
  group 'vagrant'

  listen       '127.0.0.1:9000'
  listen_user  'vagrant'
  listen_group 'vagrant'
end

# needs to be installed later
package 'php7.2-curl' do
  action :install
end

# composer setup
include_recipe 'composer::self_update'

composer_project node['matomo']['docroot'] do
  dev    true
  quiet  true
  action :install
end

# redis setup
#unless node['matomo']['vm_type'] == 'minimal'
#  include_recipe 'redisio'
#  include_recipe 'redisio::enable'
#end

execute 'matomo_database' do
  command <<-DBSQL
  mysql -uroot -e '
      CREATE DATABASE IF NOT EXISTS \`#{node['matomo']['mysql_database']}\`
  '
  DBSQL
end

execute 'matomo_database_user' do
  command <<-USERSQL
  mysql -uroot -e '
      GRANT ALL ON \`#{node['matomo']['mysql_database']}\`.*
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

  execute 'matomo_tests_database_user' do
    command <<-USERSQL
    mysql -uroot -e '
        GRANT ALL ON \`matomo_tests\`.*
        TO "matomo"@"localhost"
        IDENTIFIED BY "matomo";
    '
    USERSQL
  end
end

# install some packages required to run /matomo/tests/lib/geoip-files/writeTestFiles.pl
include_recipe 'build-essential::default'
build_essential 'install compilation tools' # required to compile modules

include_recipe 'perl::default'
cpan_module 'MaxMind::DB::Writer::Serializer'
cpan_module 'File::Slurper'
cpan_module 'Cpanel::JSON::XS'
