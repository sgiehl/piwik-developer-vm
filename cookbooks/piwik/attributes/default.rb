Kernel.load('/vagrant/plugins/piwik.rb')

config_file = File.expand_path('/vagrant/config.rb')
config      = Piwik::Config.new(config_file)

default['piwik']['docroot']     = '/srv/piwik'
default['piwik']['server_name'] = config.server_name
default['piwik']['type']        = config.type

default['redisio']['bin_path']        = '/usr/bin'
default['redisio']['package_install'] = true
default['redisio']['version']         = nil
