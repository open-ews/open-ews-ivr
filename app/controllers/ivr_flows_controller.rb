class IVRFlowsController
  attr_reader :twilio_request_parser

  def initialize(**options)
    @twilio_request_parser = options.fetch(:twilio_request_parser) { TwilioRequestParser.new }
  end

  def handle(request:, route:)
    twilio_request = twilio_request_parser.parse(request)
    ivr_flow = IVRFlow::Collection.find(route.parameters.fetch(:id))
    handler = ivr_flow.handler.new(request: twilio_request)
    handler.call
  end
end
