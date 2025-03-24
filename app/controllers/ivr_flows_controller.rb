class IVRFlowsController
  attr_reader :twilio_request_parser

  def initialize(**options)
    @twilio_request_parser = options.fetch(:twilio_request_parser) { TwilioRequestParser.new }
  end

  def create(request:, route:)
    ivr_flow = IVRFlow::Collection.find(route.parameters.fetch(:id))
    twilio_request = twilio_request_parser.parse(request)
    handler = ivr_flow.handler.new(twilio_request)
    handler.call
  end
end
