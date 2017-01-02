Kernel.load('/vagrant/config.rb')

default['piwik']['server_name'] = Piwik::Config.server_name

default['redisio']['bin_path']        = '/usr/bin'
default['redisio']['package_install'] = true
default['redisio']['version']         = nil
