class TwilioRecordingStatusCallbackRequestParser
  class Parser
    attr_reader :request

    def initialize(request)
      @request = request
    end

    def call
      twilio = TwilioRecordingStatusCallbackRequest::Twilio.new(
        url:,
        duration:,
        start_time:,
        status:,
        signature: request.headers.fetch("x-twilio-signature")
      )
      TwilioRecordingStatusCallbackRequest.new(request, twilio)
    end

    private

    def params
      @params ||= URI.decode_www_form(request.body).to_h
    end

    def url
      params.fetch("RecordingUrl")
    end

    def duration
      params.fetch("RecordingDuration")
    end

    def start_time
      params.fetch("RecordingStartTime")
    end

    def status
      params.fetch("RecordingStatus")
    end
  end

  def parse(...)
    Parser.new(...).call
  end
end
