# -*- mode: ruby -*-
# vi: set ft=ruby :

Kernel.load('./plugins/piwik.rb')

config_file = File.expand_path('./config.rb', File.dirname(__FILE__))
config      = Piwik::Config.new(config_file)
vm          = Piwik::DevVM.new(config)

vm.check_requirements!

Vagrant.configure('2') do |global|
  if Vagrant.has_plugin?('vagrant-hostmanager')
    global.hostmanager.enabled           = true
    global.hostmanager.manage_host       = true
    global.hostmanager.ignore_private_ip = false
    global.hostmanager.include_offline   = true
  end

  global.ssh.forward_agent = true

  global.vm.define 'piwik' do |piwik|
    piwik.vm.box      = 'threatstack/ubuntu-14.04-amd64'
    piwik.vm.hostname = config.server_name

    piwik.vm.network 'private_network', ip: '192.168.99.100'

    piwik.vm.synced_folder config.source,
      '/srv/piwik',
        owner: 'vagrant',
        group: 'vagrant'

    piwik.vm.provider 'virtualbox' do |vb|
      vb.customize ['modifyvm', :id, '--name', 'piwik']

      vb.cpus   = 2
      vb.gui    = false
      vb.memory = 2048
    end

    piwik.vm.provision 'bootstrap',
      :type => 'shell',
      :path => 'bootstrap.sh'

      piwik.vm.provision 'chef_solo' do |chef|
        chef.cookbooks_path = %w(berks-cookbooks cookbooks)

        chef.add_recipe 'piwik'
      end
  end
end
