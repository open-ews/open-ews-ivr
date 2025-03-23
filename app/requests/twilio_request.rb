class TwilioRequest < SimpleDelegator
  Twilio = Data.define(:from, :to, :digits, :payload, :signature)

  attr_reader :twilio

  def initialize(request, twilio)
    @twilio = twilio
    super(request)
  end
end
