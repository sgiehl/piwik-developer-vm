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
      matomo.vm.box = "ubuntu/bionic64"
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
                                "/srv/matomo/plugins/#{plugin[1]}",
                                owner: 'vagrant',
                                group: 'vagrant'
      end
    end

    matomo.vm.provider 'virtualbox' do |vb|
      vb.customize ['modifyvm', :id, '--name', config.get('vm_name')]

      vb.cpus   = 2
      vb.gui    = false
      vb.memory = config.get('vm_type') == 'minimal' ? 4096 : 8192
    end

    # Needed for running UI tests (on windows)
    if Vagrant::Util::Platform.windows?
        # Mount some test folders & files as creating symlinks won't work on Windows
        matomo.vm.provision 'mount',
         type:   'shell',
         inline: 'for i in libs plugins tests misc;
                  do
                    rm -rf /srv/matomo/tests/PHPUnit/proxy/$i
                    mkdir -p /srv/matomo/tests/PHPUnit/proxy/$i
                    sudo mount --bind /srv/matomo/$i /srv/matomo/tests/PHPUnit/proxy/$i
                  done',
         run:    'always'

        matomo.vm.provision 'mount_files',
         type:   'shell',
         inline: 'for i in piwik.js matomo.js;
                  do
                    rm -rf /srv/matomo/tests/PHPUnit/proxy/$i
                    touch /srv/matomo/tests/PHPUnit/proxy/$i
                    sudo mount --bind /srv/matomo/$i /srv/matomo/tests/PHPUnit/proxy/$i
                  done',
         run:    'always'

        # ensure tmp folder is located within the vm to speed up access
        matomo.vm.provision 'mount_tmp',
          type:   'shell',
          inline: 'mkdir -m 777 -p /srv/matomo_tmp
                   sudo mount --bind /srv/matomo_tmp /srv/matomo/tmp/',
          run:    'always'

        # ensure node_modules are located within the vm (doesn't work located on windows fs, due to path depth)
        matomo.vm.provision 'mount_node_modules',
          type:   'shell',
          inline: 'mkdir -m 777 -p /srv/matomo_node_modules
                   mkdir -m 777 -p /srv/matomo/tests/lib/screenshot-testing/node_modules
                   sudo mount --bind /srv/matomo_node_modules /srv/matomo/tests/lib/screenshot-testing/node_modules',
          run:    'always'

    end

    matomo.vm.provision 'bootstrap',
                        type: 'shell',
                        path: 'bootstrap.sh'

    matomo.vm.provision 'chef_solo' do |chef|
      chef.arguments = "--chef-license accept"
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
