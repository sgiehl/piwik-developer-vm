packages = %w(mysql-server php5 php5-mysql)

packages.each do |pkg|
  apt_package pkg do
  end
end

include_recipe 'composer::self_update'
