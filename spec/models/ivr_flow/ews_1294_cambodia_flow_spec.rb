require "spec_helper"

module IVRFlow
  RSpec.describe EWS1294CambodiaFlow do
    it "plays the introduction" do
      request = build_twilio_request(
        path: "/ivr_flows/ews_1294_cambodia"
      )
      flow = EWS1294CambodiaFlow.new(request:)

      response = flow.call

      twiml = response_twiml(response_body(response))

      expect(twiml).to include(
        "Play" => "https://s3.ap-southeast-1.amazonaws.com/audio.open-ews.org/ews_registration/introduction-khm.wav",
        "Redirect" => "/ivr_flows/ews_1294_cambodia?status=introduction_played"
      )
    end

    it "goes to the main menu" do
      request = build_twilio_request(
        path: "/ivr_flows/ews_1294_cambodia",
        query_parameters: {
          "status" => "introduction_played"
        },
        twilio_params: {
          from: "+855715100860"
        }
      )
      flow = EWS1294CambodiaFlow.new(request:)

      response = flow.call

      twiml = response_twiml(response_body(response))
      expect(twiml.fetch("Gather")).to include(
        "action" => "/ivr_flows/ews_1294_cambodia?status=main_menu_prompted",
        "Play"=> "https://s3.ap-southeast-1.amazonaws.com/audio.open-ews.org/ews_registration/main_menu-khm.mp3"
      )
    end

    it "goes to the language menu" do
      request = build_twilio_request(
        path: "/ivr_flows/ews_1294_cambodia",
        query_parameters: {
          "status" => "introduction_played"
        },
        twilio_params: {
          from: "+855715100999"
        }
      )
      flow = EWS1294CambodiaFlow.new(request:)

      response = flow.call

      twiml = response_twiml(response_body(response))
      expect(twiml.fetch("Gather")).to include(
        "action" => "/ivr_flows/ews_1294_cambodia?status=language_prompted",
        "Play"=> "https://s3.ap-southeast-1.amazonaws.com/audio.open-ews.org/ews_registration/select_language.wav"
      )
    end

    it "handles registration from the main menu" do
      request = build_twilio_request(
        path: "/ivr_flows/ews_1294_cambodia",
        query_parameters: {
          "status" => "main_menu_prompted"
        },
        twilio_params: {
          digits: 1
        }
      )
      flow = EWS1294CambodiaFlow.new(request:)

      response = flow.call

      twiml = response_twiml(response_body(response))
      expect(twiml.fetch("Gather")).to include(
        "action" => "/ivr_flows/ews_1294_cambodia?status=language_prompted",
        "Play"=> "https://s3.ap-southeast-1.amazonaws.com/audio.open-ews.org/ews_registration/select_language.wav"
      )
    end

    it "handles recording feedback" do
      request = build_twilio_request(
        path: "/ivr_flows/ews_1294_cambodia",
        query_parameters: {
          "status" => "main_menu_prompted"
        },
        twilio_params: {
          digits: 2
        }
      )
      flow = EWS1294CambodiaFlow.new(request:)

      response = flow.call

      twiml = response_twiml(response_body(response))
      expect(twiml.fetch("Gather")).to include(
        "action" => "/ivr_flows/ews_1294_cambodia?status=language_prompted",
        "Play"=> "https://s3.ap-southeast-1.amazonaws.com/audio.open-ews.org/ews_registration/select_language.wav"
      )
    end

    def response_twiml(xml)
      Hash.from_xml(xml).fetch("Response")
    end

    def response_body(response)
      Base64.decode64(response.body)
    end
  end
end
