module IVRFlow
  class Base
    attr_reader :request, :open_ews_client, :twilio_request_validator, :auth_token_fetcher

    def initialize(**options)
      @request = options.fetch(:request)
      @open_ews_client = options.fetch(:open_ews_client)
      @twilio_request_validator = options.fetch(:twilio_request_validator) { TwilioRequestValidator.new }
      @auth_token_fetcher = options.fetch(:auth_token, -> { open_ews_client.fetch_account_settings.somleng_auth_token })
    end

    private

    def validate_twilio_request!
      twilio_request_validator.validate_request(auth_token:, url: request.url, params: request.twilio.payload, signature: request.twilio.signature)
    end

    def auth_token
      @auth_token ||= auth_token_fetcher.respond_to?(:call) ? auth_token_fetcher.call : auth_token_fetcher
    end

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
