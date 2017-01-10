module Piwik
  # Configuration class for the Piwik box
  class Config
    attr_reader :name
    attr_reader :server_name
    attr_reader :source

    def initialize(config_file)
      import_config(config_file)
    end

    protected

    def import_config(config_file)
      name        = 'piwik'
      server_name = 'dev.piwik.org'
      source      = '../piwik'

      # read config file
      config_file = Pathname.new(config_file) unless config_file.is_a?(Pathname)

      instance_eval(config_file.read) if File.exist?(config_file)
      # /read config file

      @name        = name
      @server_name = server_name
      @source      = source
    end
  end
end
