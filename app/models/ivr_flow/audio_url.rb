module IVRFlow
  class AudioURL
    attr_reader :namespace, :filename, :language, :file_extension, :region, :bucket

    def initialize(**options)
      @namespace = options.fetch(:namespace)
      @filename = options.fetch(:filename)
      @language = options[:language]
      @file_extension = options.fetch(:file_extension, "wav")
      @region = options.fetch(:region) { AppSettings.fetch(:audio_bucket_region) }
      @bucket = options.fetch(:bucket) { AppSettings.fetch(:audio_bucket) }
    end

    def url
      key = [ "#{namespace}/#{filename}", language ].compact.join("-")
      "https://s3.#{region}.amazonaws.com/#{bucket}/#{key}.#{file_extension}"
    end
  end
end
