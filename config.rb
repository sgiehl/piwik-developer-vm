module Piwik
  # Configuration class for the Piwik box
  class Config
    @server_name = 'dev.piwik.org'
    @source = '../piwik'

    # do not edit below this line!

    class << self
      attr_reader :server_name
      attr_reader :source
    end
  end
end
