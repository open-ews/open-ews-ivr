module IVRFlow
  class Base
    attr_reader :request, :twilio_request_validator

    def initialize(**options)
      @request = options.fetch(:request)
      @twilio_request_validator = options.fetch(:twilio_request_validator) { TwilioRequestValidator.new }
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

    def status
      request.query_parameters.fetch("status", "answered")
    end
  end
end
