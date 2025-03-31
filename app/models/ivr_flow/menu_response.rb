module IVRFlow
  class MenuResponse
    attr_reader :request

    def initialize(request)
      @request = request
    end

    def start_over?
      request.twilio.digits == "*"
    end

    def choice
      request.twilio.digits.to_s.empty? ? nil : request.twilio.digits.to_i
    end
  end
end
