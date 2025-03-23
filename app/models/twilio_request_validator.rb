class TwilioRequestValidator
  def validate_request(auth_token:, signature:)

    if request_validator.validate(original_url, params, signature)
      @app.call(env)
    else

    end
  end

  def build_signature_for(auth_token:, url:, params:)
    request_validator_for(auth_token).build_signature_for(url, params)
  end

  def request_validator_for(auth_token)
    Twilio::Security::RequestValidator.new(auth_token)
  end
end
