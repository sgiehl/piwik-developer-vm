
package 'mysql-server' do
  action :install
end

execute 'matomo_database' do
  command <<-DBSQL
  mysql -uroot -e '
      CREATE DATABASE IF NOT EXISTS \`#{node['matomo']['mysql_database']}\`
  '
  DBSQL
end

execute 'matomo_database_settings' do
  command <<-DBSQL
  mysql -uroot -e '
      SET @@GLOBAL.innodb_flush_log_at_trx_commit = 2;
      SET @@GLOBAL.max_allowed_packet = 67108864;
  '
  DBSQL
end

execute 'matomo_database_user' do
  command <<-USERSQL
  mysql -uroot -e '
      GRANT ALL ON *.*
      TO "#{node['matomo']['mysql_username']}"@"localhost"
      IDENTIFIED BY "#{node['matomo']['mysql_password']}";
  '
  USERSQL
end

unless node['matomo']['vm_type'] == 'minimal'
  execute 'matomo_tests_database' do
    command <<-DBSQL
    mysql -uroot -e '
        CREATE DATABASE IF NOT EXISTS \`matomo_tests\`
    '
    DBSQL
  end
end

# mysql setup
# HACK: ensure mysql is started in docker after installation
execute 'mysql_start' do # ~FC004
  command '/etc/init.d/mysql start || true'
end