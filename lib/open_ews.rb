module OpenEWS
  class << self
    def configure
      yield(configuration)
      configuration
    end

    def configuration
      @configuration ||= Configuration.new
    end
    alias config configuration
  end
end

require_relative "open_ews/configuration"
require_relative "open_ews/client"
