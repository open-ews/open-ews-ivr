class TwilioRequestValidator
  def validate_request(auth_token:, url:, params:, signature:)
    request_validator_for(auth_token).validate(url, params, signature)
  end

  def build_signature_for(auth_token:, url:, params:)
    request_validator_for(auth_token).build_signature_for(url, params)
  end

  def request_validator_for(auth_token)
    Twilio::Security::RequestValidator.new(auth_token)
  end
end
