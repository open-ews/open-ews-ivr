module IVRFlow
  class Base
    attr_reader :request

    def initialize(request:)
      @request = request
    end

    private

    def build_redirect_url(**params)
      uri = URI(request.path)
      uri.query = URI.encode_www_form(params)
      uri.to_s
    end

    def build_audio_url(**)
      AudioURL.new(**).url
    end

    def status
      request.query_parameters.fetch("status", "answered")
    end
  end
end
