module IVRFlow
  class Menu
    attr_reader :audio_namespace, :request

    def initialize(**options)
      @audio_namespace = options.fetch(:audio_namespace)
      @request = options.fetch(:request)
    end

    def prompt
      gather(action: response_url) do |gather|
        gather.play(url: audio_url.url)
      end
    end

    private

    def audio_url(**)
      @audio_url ||= AudioURL.new(namespace: audio_namespace, **)
    end

    def response_url
      uri = URI(request.path)
      uri.query = URI.encode_www_form(status: self.class.response_status)
      uri.to_s
    end

    def gather(action:)
      Twilio::TwiML::VoiceResponse.new do |response|
        response.gather(action_on_empty_result: true, action:) do |gather|
          yield(gather)
        end
      end
    end
  end
end
