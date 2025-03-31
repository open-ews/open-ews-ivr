module IVRFlow
  class TwiMLBuilder
    def prompt(action:, audio_url:, **options)
      Twilio::TwiML::VoiceResponse.new do |response|
        options.fetch(:before).call(response) if options.key?(:before)
        response.gather(action_on_empty_result: true, action:) do |gather|
          gather.play(url: audio_url)
        end
      end
    end

    def hangup(**options)
      Twilio::TwiML::VoiceResponse.new do |response|
        options.fetch(:before).call(response) if options.key?(:before)
        response.hangup
      end
    end

    def record(action:, **options)
      Twilio::TwiML::VoiceResponse.new do |response|
        options.fetch(:before).call(response) if options.key?(:before)
        response.record(action:)
      end
    end
  end
end
