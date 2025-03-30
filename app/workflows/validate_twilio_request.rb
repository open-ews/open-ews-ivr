class ValidateTwilioRequest
  attr_reader :request, :auth_token, :twilio_request_validator

  def initialize(request:, auth_token:, **options)
    @request = request
    @auth_token = auth_token
    @twilio_request_validator = options.fetch(:twilio_request_validator) { TwilioRequestValidator.new }
  end

  def self.call(...)
    new(...).call
  end

  def call
    twilio_request_validator.validate_request(
      auth_token:,
      url: request.url,
      params: request.twilio.payload,
      signature: request.twilio.signature
    )
  end
end
