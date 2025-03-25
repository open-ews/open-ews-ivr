class TwilioRecordingStatusCallbackRequest < SimpleDelegator
  Twilio = Data.define(:url, :duration, :start_time, :status, :signature)

  attr_reader :twilio

  def initialize(request, twilio)
    super(request)
    @twilio = twilio
  end
end
