# -*- mode: ruby -*-
# vi: set ft=ruby :

Kernel.load(File.expand_path('./plugins/matomo.rb', File.dirname(__FILE__)))

chef_run_list  = ['recipe[matomo]']
config         = Matomo::Config.new
config_default = File.expand_path('./config.yml', File.dirname(__FILE__))
config_local   = File.expand_path('./config.local.yml', File.dirname(__FILE__))

config.parse_file(config_default) if File.exist?(config_default)
config.parse_file(config_local) if File.exist?(config_local)

Matomo::DevVM.new(config).check_requirements!

Vagrant.configure('2') do |global|
  if Vagrant.has_plugin?('vagrant-hostmanager')
    global.hostmanager.enabled           = true
    global.hostmanager.ignore_private_ip = false
    global.hostmanager.include_offline   = true

    # /etc/hosts is not writable on NixOS
    global.hostmanager.manage_host = !File.exist?('/etc/NIXOS')
  end

  global.ssh.forward_agent = true

  global.vm.define config.get('vm_name') do |matomo|
    matomo.vm.box      = 'threatstack/ubuntu-14.04-amd64'
    matomo.vm.hostname = config.get('server_name')

    matomo.vm.network 'private_network', ip: config.get('vm_ip')

    matomo.vm.synced_folder config.get('source'),
                            '/srv/matomo',
                            owner: 'vagrant',
                            group: 'vagrant'

    if File.directory?(File.expand_path(config.get('source_device_detector')))
      matomo.vm.synced_folder config.get('source_device_detector'),
                              '/srv/device-detector',
                              owner: 'vagrant',
                              group: 'vagrant'

      chef_run_list << 'recipe[matomo-device-detector]'
    end

    if config.get('plugin_glob') && config.get('plugin_pattern')
      Dir.glob(config.get('plugin_glob')).each do |glob|
        plugin_re = Regexp.new(config.get('plugin_pattern'))
        plugin    = plugin_re.match(File.basename(glob))

        next unless plugin

        matomo.vm.synced_folder glob,
                                "/srv/matomo/plugins/#{plugin}",
                                owner: 'vagrant',
                                group: 'vagrant'
      end
    end

    matomo.vm.provider 'virtualbox' do |vb|
      vb.customize ['modifyvm', :id, '--name', config.get('vm_name')]

      vb.cpus   = 2
      vb.gui    = false
      vb.memory = config.get('vm_type') == 'minimal' ? 2048 : 4096
    end

    matomo.vm.provision 'bootstrap',
                        type: 'shell',
                        path: 'bootstrap.sh'

    matomo.vm.provision 'chef_solo' do |chef|
      chef.cookbooks_path = %w[cookbooks berks-cookbooks]
      chef.run_list = chef_run_list

      chef.json = {
        matomo: {
          mysql_database: config.get('mysql_database'),
          mysql_password: config.get('mysql_password'),
          mysql_username: config.get('mysql_username'),
          server_name:    config.get('server_name'),
          vm_type:        config.get('vm_type')
        }
      }
    end
  end
end
