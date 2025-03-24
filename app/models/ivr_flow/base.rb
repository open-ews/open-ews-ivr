module IVRFlow
  class Base
    attr_reader :request

    def initialize(**options)
      @request = options.fetch(:request)
    end

    private

    def build_redirect_url(**params)
      uri = URI(request.path)
      uri.query = URI.encode_www_form(params)
      uri.to_str
    end

    def build_audio_url(**)
      AudioURL.new(**).url
    end
  end
end
