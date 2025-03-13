module IVRFlow
  class EWS1294RegistrationFlow < Base
    def call
      response = Twilio::TwiML::VoiceResponse.new do |r|
        r.say(message: 'hello there', voice: 'alice')
      end

      TwiMLResponse.new(twiml: response.to_s)
    end
  end
end
