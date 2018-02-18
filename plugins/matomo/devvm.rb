module Matomo
  # Manages the Matomo box.
  class DevVM
    REPO = 'https://github.com/matomo-org/matomo.git'.freeze

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

      matomo_js = File.join(@config.get('source'), 'piwik.js')

      error_source_missing(@config.get('source')) unless File.exist?(matomo_js)
    end

    private

    def error_source_missing(source)
      @ui.error "Matomo not found at location '#{source}'"
      @ui.info ''
      @ui.info 'Please update your config.yml or download the source.'
      @ui.info 'If your system is configured, this command should work:'
      @ui.info ''

      command = 'git'
      command = 'git.exe' if Vagrant::Util::Platform.windows?

      @ui.info "> #{command} clone #{REPO} #{source} --recursive"

      exit
    end
  end
end
