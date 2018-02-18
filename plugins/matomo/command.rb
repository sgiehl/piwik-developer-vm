module Matomo
  # Provides utility methods to interact with vagrant commands.
  class Command
    # Checks if vagrant was called to bring up a box.
    def self.up?
      ARGV.include?('up') || ARGV.include?('reload')
    end
  end
end
