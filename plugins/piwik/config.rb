module Piwik
  # Configuration class for the Piwik box
  class Config
    attr_reader :server_name
    attr_reader :source

    def initialize(config_file)
      set_defaults
      import_config(config_file)
    end

    protected

    attr_writer :server_name
    attr_writer :source

    def import_config(config_file)
      return unless File.exist?(config_file)

      # rubocop:disable UselessAssignment
      config      = self
      config_file = Pathname.new(config_file) unless config_file.is_a?(Pathname)
      # rubocop:enable UselessAssignment

      instance_eval(config_file.read)
    end

    def set_defaults
      @server_name = 'dev.piwik.org'
      @source      = '../piwik'
    end
  end
end
