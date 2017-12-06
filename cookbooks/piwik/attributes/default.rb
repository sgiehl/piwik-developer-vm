Kernel.load('/vagrant/plugins/piwik.rb')

config_file = File.expand_path('/vagrant/config.yml')
config      = Piwik::Config.new(config_file)

default['piwik']['vm_type'] = config.get('vm_type')

default['piwik']['docroot']        = '/srv/piwik'
default['piwik']['mysql_database'] = config.get('mysql_database')
default['piwik']['mysql_password'] = config.get('mysql_password')
default['piwik']['mysql_username'] = config.get('mysql_username')
default['piwik']['server_name']    = config.get('server_name')

default['redisio']['bin_path']        = '/usr/bin'
default['redisio']['package_install'] = true
default['redisio']['version']         = nil

default['php']['directives'] = { :'xdebug.max_nesting_level' => 200 }
