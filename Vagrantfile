# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure('2') do |config|
  config.ssh.forward_agent = true

  config.vm.define 'piwik' do |piwik|
    piwik.vm.box      = 'threatstack/ubuntu-14.04-amd64'
    piwik.vm.hostname = 'dev.piwik.org'

    piwik.vm.network 'private_network', ip: '192.168.99.100'

    piwik.vm.provider 'virtualbox' do |vb|
      vb.customize ['modifyvm', :id, '--name', 'piwik']

      vb.cpus   = 2
      vb.gui    = false
      vb.memory = 2048
    end

    piwik.vm.provision 'bootstrap',
      :type => 'shell',
      :path => 'bootstrap.sh'
  end
end
