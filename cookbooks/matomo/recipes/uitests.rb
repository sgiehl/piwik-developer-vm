
include_recipe "chrome"
include_recipe "nodejs::nodejs_from_binary"

npm_package 'screenshot-testing' do
    path '/srv/matomo/tests/lib/screenshot-testing'
    json true
    user 'vagrant'
end

# imagemagick setup
include_recipe 'imagemagick::default'

# ensure the same fonts are used as on travis
execute 'copy_fonts' do
  command '[ -d /home/vagrant/.fonts ] || mkdir /home/vagrant/.fonts; [ ! -d /srv/matomo/tests/travis/fonts ] || cp -f /srv/matomo/tests/travis/fonts/* /home/vagrant/.fonts'
  user  'vagrant'
  group 'vagrant'
end