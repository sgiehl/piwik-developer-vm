module Piwik
  # Manages the Piwik box.
  class DevVM
    REPO = 'https://github.com/piwik/piwik.git'.freeze

    def initialize(config)
      @config = config
      @ui     = Vagrant::UI::Colored.new
    end

    # Checks various requirements for the box to properly come up.
    #
    # Non-starting commands are ignored.
    # Will exit if an error is found.
    def check_requirements!
      return unless Command.up?

      piwik_js = File.join(@config.source, 'piwik.js')

      error_source_missing(@config.source) unless File.exist?(piwik_js)
    end

    private

    def error_source_missing(source)
      @ui.error "Piwik not found at location '#{source}'"
      @ui.info ''
      @ui.info 'Please update your config.rb or download the source.'
      @ui.info 'If your system is configured, this command should work:'
      @ui.info ''

      command = 'git'
      command = 'git.exe' if Vagrant::Util::Platform.windows?

      @ui.info "> #{command} clone #{REPO} #{source} --recursive"

      exit
    end
  end
end
