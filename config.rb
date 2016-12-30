module Piwik
  # Configuration class for the Piwik box
  class Config
    @source = '../piwik'

    # do not edit below this line!

    class << self
      attr_reader :source
    end
  end
end
