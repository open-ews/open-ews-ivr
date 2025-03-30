module IVRFlow
  class AudioURL
    attr_reader :namespace, :filename, :language, :file_extension, :host

    def initialize(**options)
      @namespace = options.fetch(:namespace)
      @filename = options.fetch(:filename)
      @language = options[:language]
      @file_extension = options.fetch(:file_extension, "wav")
      @host = options.fetch(:host) { AppSettings.fetch(:audio_host) }
    end

    def url
      key = [ "#{namespace}/#{filename}", language ].compact.join("-")
      uri = URI(host)
      uri.path = "/#{key}.#{file_extension}"
      uri.to_s
    end
  end
end
