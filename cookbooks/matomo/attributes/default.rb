default['matomo']['vm_type'] = 'minimal'

default['matomo']['docroot']        = '/srv/matomo'
default['matomo']['mysql_database'] = 'matomo'
default['matomo']['mysql_password'] = 'matomo'
default['matomo']['mysql_username'] = 'matomo'
default['matomo']['server_name']    = 'dev.matomo.org'

default['redisio']['bin_path']        = '/usr/bin'
default['redisio']['package_install'] = true
default['redisio']['version']         = nil

default['php']['directives'] = { :'xdebug.max_nesting_level' => 200, :'memory_limit' => '512m' }

default['php']['version']          = '8.0.9'
default['php']['checksum']         = 'a554a510190e726ebe7157fb00b4aceabdb50c679430510a3b93cbf5d7546e44'
default['php']['conf_dir']         = '/etc/php/8.0/cli'
default['php']['src_deps']         = %w(libbz2-dev libc-client2007e-dev libcurl4-gnutls-dev libfreetype6-dev libgmp3-dev libjpeg62-dev libkrb5-dev libmcrypt-dev libpng-dev libssl-dev pkg-config libxml2-dev libsqlite3-dev libonig-dev)
default['php']['packages']         = %w(php8.0-cgi php8.0 php8.0-dev php8.0-cli php-pear)
default['php']['fpm_package']      = 'php8.0-fpm'
default['php']['fpm_pooldir']      = '/etc/php/8.0/fpm/pool.d'
default['php']['fpm_service']      = 'php8.0-fpm'
default['php']['fpm_socket']       = '/var/run/php/php8.0-fpm.sock'
default['php']['fpm_default_conf'] = '/etc/php/8.0/fpm/pool.d/www.conf'
default['php']['fpm_conf_dir']     = '/etc/php/8.0/fpm'
default['php']['enable_mod']       = '/usr/sbin/phpenmod'
default['php']['disable_mod']      = '/usr/sbin/phpdismod'
default['php']['ext_conf_dir']     = '/etc/php/8.0/mods-available'
