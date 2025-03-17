module IVRFlow
  class Menu
    attr_reader :request

    def initialize(request:)
      @request = request
    end

    def prompt(action:, audio_url:)
      Twilio::TwiML::VoiceResponse.new do |response|
        response.gather(action_on_empty_result: true, action:) do |gather|
          gather.play(url: audio_url)
        end
      end
    end
  end
end
