Kernel.load('/vagrant/plugins/piwik.rb')

config         = Piwik::Config.new
config_default = '/vagrant/config.yml'
config_local   = '/vagrant/config.local.yml'

config.parse_file(config_default) if File.exist?(config_default)
config.parse_file(config_local) if File.exist?(config_local)

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
