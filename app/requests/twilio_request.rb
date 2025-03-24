class TwilioRequest < SimpleDelegator
  Twilio = Data.define(:from, :to, :direction, :beneficiary, :digits, :payload, :signature)

  attr_reader :twilio

  def initialize(request, twilio)
    super(request)
    @twilio = twilio
  end
end
