class TwilioRequestParser
  class Parser
    attr_reader :request

    def initialize(request)
      @request = request
    end

    def call
      twilio = TwilioRequest::Twilio.new(
        from:,
        to:,
        direction:,
        beneficiary:,
        digits:,
        payload: params,
        signature: request.headers.fetch("x-twilio-signature")
      )
      TwilioRequest.new(request, twilio)
    end

    private

    def params
      @params ||= URI.decode_www_form(request.body).to_h
    end

    def digits
      params.key?("Digits") && !params.fetch("Digits").to_s.empty? ? params.fetch("Digits") : nil
    end

    def direction
      params.fetch("Direction")
    end

    def from
      params.fetch("From")
    end

    def to
      params.fetch("To")
    end

    def beneficiary
      direction == "inbound" ? from : to
    end
  end

  def parse(...)
    Parser.new(...).call
  end
end
