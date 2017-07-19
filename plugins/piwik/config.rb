module Piwik
  # Configuration class for the Piwik box
  class Config
    attr_reader :mysql_database
    attr_reader :mysql_password
    attr_reader :mysql_username
    attr_reader :name
    attr_reader :plugin_glob
    attr_reader :plugin_pattern
    attr_reader :server_name
    attr_reader :source
    attr_reader :source_device_detector
    attr_reader :type

    def initialize(config_file)
      import_config(config_file)
    end

    protected

    # rubocop:disable AbcSize
    # rubocop:disable MethodLength
    def import_config(config_file)
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

      # read config file
      config_file = Pathname.new(config_file) unless config_file.is_a?(Pathname)

      instance_eval(config_file.read) if File.exist?(config_file)
      # /read config file

      @name                   = name
      @server_name            = server_name
      @source                 = source
      @source_device_detector = source_device_detector
      @type                   = type

      @mysql_database = mysql_database
      @mysql_password = mysql_password
      @mysql_username = mysql_username

      @plugin_glob    = plugin_glob
      @plugin_pattern = plugin_pattern
    end
    # rubocop:enable MethodLength
    # rubocop:enable AbcSize
  end
end
