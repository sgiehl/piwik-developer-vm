# rubocop:disable UselessAssignment

vm_name = 'piwik'
vm_type = 'minimal'

server_name            = 'dev.piwik.org'
source                 = '../piwik'
source_device_detector = '../device-detector'

mysql_database = 'piwik'
mysql_password = 'piwik'
mysql_username = 'piwik'

plugin_glob    = '../{piwik-plugin,plugin}-*/'
plugin_pattern = /plugin\-([a-zA-Z]*)$/
