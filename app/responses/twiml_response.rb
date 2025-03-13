
require_relative "alb_response/ok_response"

class TwiMLResponse < ALBResponse::OKResponse
  def initialize(twiml:, **options)
    super(body: twiml, content_type: "application/xml", **options)
  end
end
