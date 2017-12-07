default['piwik']['vm_type'] = 'minimal'

default['piwik']['docroot']        = '/srv/piwik'
default['piwik']['mysql_database'] = 'piwik'
default['piwik']['mysql_password'] = 'piwik'
default['piwik']['mysql_username'] = 'piwik'
default['piwik']['server_name']    = 'dev.piwik.org'

default['redisio']['bin_path']        = '/usr/bin'
default['redisio']['package_install'] = true
default['redisio']['version']         = nil

default['php']['directives'] = { :'xdebug.max_nesting_level' => 200 }
