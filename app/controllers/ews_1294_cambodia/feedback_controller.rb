module EWS1294Cambodia
  class FeedbackController
    attr_reader :request_parser

    def initialize(**options)
      @request_parser = options.fetch(:request_parser) { TwilioRecordingStatusCallbackRequestParser.new }
    end

    def create(request:, **)
      request = request_parser.parse(request)
      IVRFlow::EWS1294CambodiaFlow.new(request).process_recording
      ALBResponse::OKResponse.new
    end
  end
end
