# rubocop:disable UselessAssignment

name                   = 'piwik'
server_name            = 'dev.piwik.org'
source                 = '../piwik'
source_device_detector = '../device-detector'
type                   = 'minimal'

mysql_database = 'piwik'
mysql_password = 'piwik'
mysql_username = 'piwik'

plugin_glob    = '../{piwik-plugin,plugin}-*/'
plugin_pattern = /plugin\-([a-zA-Z]*)$/
