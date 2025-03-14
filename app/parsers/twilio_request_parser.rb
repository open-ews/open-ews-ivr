class TwilioRequestParser
  class Parser
    attr_reader :request

    def initialize(request)
      @request = request
    end

    def call
      twilio = TwilioRequest::Twilio.new(
        from: params.fetch("From"),
        to: params.fetch("To"),
        digits:
      )
      TwilioRequest.new(request, twilio)
    end

    private

    def params
      @params ||= URI.decode_www_form(request.body)
    end

    def digits
      params.key?("Digits") && !params.fetch("Digits").to_s.empty? ? params.fetch("Digits").to_i : nil
    end
  end

  def parse(...)
    Parser.new(...).call
  end
end
