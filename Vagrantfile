# -*- mode: ruby -*-
# vi: set ft=ruby :
# rubocop:disable BlockLength

Kernel.load(File.expand_path('./plugins/piwik.rb', File.dirname(__FILE__)))

chef_run_list  = ['recipe[piwik]']
config         = Piwik::Config.new
config_default = File.expand_path('./config.yml', File.dirname(__FILE__))
config_local   = File.expand_path('./config.local.yml', File.dirname(__FILE__))

config.parse_file(config_default) if File.exist?(config_default)
config.parse_file(config_local) if File.exist?(config_local)

Piwik::DevVM.new(config).check_requirements!

Vagrant.configure('2') do |global|
  if Vagrant.has_plugin?('vagrant-hostmanager')
    global.hostmanager.enabled           = true
    global.hostmanager.ignore_private_ip = false
    global.hostmanager.include_offline   = true

    # /etc/hosts is not writable on NixOS
    global.hostmanager.manage_host = !File.exist?('/etc/NIXOS')
  end

  global.ssh.forward_agent = true

  global.vm.define config.get('vm_name') do |piwik|
    piwik.vm.box      = 'threatstack/ubuntu-14.04-amd64'
    piwik.vm.hostname = config.get('server_name')

    piwik.vm.network 'private_network', ip: config.get('vm_ip')

    piwik.vm.synced_folder config.get('source'),
                           '/srv/piwik',
                           owner: 'vagrant',
                           group: 'vagrant'

    if File.directory?(File.expand_path(config.get('source_device_detector')))
      piwik.vm.synced_folder config.get('source_device_detector'),
                             '/srv/device-detector',
                             owner: 'vagrant',
                             group: 'vagrant'

      chef_run_list << 'recipe[piwik-device-detector]'
    end

    if config.get('plugin_glob') && config.get('plugin_pattern')
      Dir.glob(config.get('plugin_glob')).each do |glob|
        plugin_re = Regexp.new(config.get('plugin_pattern'))
        plugin    = plugin_re.match(File.basename(glob))

        next unless plugin

        piwik.vm.synced_folder glob,
                               "/srv/piwik/plugins/#{plugin}",
                               owner: 'vagrant',
                               group: 'vagrant'
      end
    end

    piwik.vm.provider 'virtualbox' do |vb|
      vb.customize ['modifyvm', :id, '--name', config.get('vm_name')]

      vb.cpus   = 2
      vb.gui    = false
      vb.memory = config.get('vm_type') == 'minimal' ? 2048 : 4096
    end

    piwik.vm.provision 'bootstrap',
                       type: 'shell',
                       path: 'bootstrap.sh'

    piwik.vm.provision 'chef_solo' do |chef|
      chef.cookbooks_path = %w[cookbooks berks-cookbooks]
      chef.run_list = chef_run_list
    end
  end
end
