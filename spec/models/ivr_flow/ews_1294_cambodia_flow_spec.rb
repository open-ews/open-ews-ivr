require "spec_helper"

module IVRFlow
  RSpec.describe EWS1294CambodiaFlow do
    it "plays the introduction" do
      request = build_ivr_request
      flow = EWS1294CambodiaFlow.new(request)

      response = flow.call

      twiml = response_twiml(response_body(response))
      expect(twiml).to include(
        "Play" => "https://uploads.open-ews.org/ews_1294_cambodia/introduction-khm.wav",
        "Redirect" => "/ivr_flows/ews_1294_cambodia?status=introduction_played"
      )
    end

    it "goes to the main menu (for selected beneficiaries)" do
      request = build_ivr_request(
        query_parameters: {
          "status" => "introduction_played"
        },
        twilio: {
          params: {
            from: "+855715100860"
          }
        }
      )
      flow = EWS1294CambodiaFlow.new(request)

      response = flow.call

      twiml = response_twiml(response_body(response))
      expect(twiml.fetch("Gather")).to include(
        "action" => "/ivr_flows/ews_1294_cambodia?status=main_menu_prompted",
        "Play"=> "https://uploads.open-ews.org/ews_1294_cambodia/main_menu-khm.mp3"
      )
    end

    it "goes to the language menu" do
      request = build_ivr_request(
        query_parameters: {
          "status" => "introduction_played"
        }
      )
      flow = EWS1294CambodiaFlow.new(request)

      response = flow.call

      twiml = response_twiml(response_body(response))
      expect(twiml.fetch("Gather")).to include(
        "action" => "/ivr_flows/ews_1294_cambodia?status=language_prompted",
        "Play"=> "https://uploads.open-ews.org/ews_1294_cambodia/select_language.wav"
      )
    end

    it "handles registration from the main menu" do
      request = build_ivr_request(
        query_parameters: {
          "status" => "main_menu_prompted"
        },
        twilio: {
          params: {
            digits: 1
          }
        }
      )
      flow = EWS1294CambodiaFlow.new(request)

      response = flow.call

      twiml = response_twiml(response_body(response))
      expect(twiml.fetch("Gather")).to include(
        "action" => "/ivr_flows/ews_1294_cambodia?status=language_prompted",
        "Play"=> "https://uploads.open-ews.org/ews_1294_cambodia/select_language.wav"
      )
    end

    it "handles recording feedback from the main menu" do
      request = build_ivr_request(
        query_parameters: {
          "status" => "main_menu_prompted"
        },
        twilio: {
          params: {
            digits: 2
          }
        }
      )
      flow = EWS1294CambodiaFlow.new(request)

      response = flow.call

      twiml = response_twiml(response_body(response))
      expect(twiml).to include(
        "Play" => "https://uploads.open-ews.org/ews_1294_cambodia/record_feedback_instructions-khm.mp3",
        "Record" => include(
          "action" => "/ivr_flows/ews_1294_cambodia?status=feedback_recorded"
        )
      )
    end

    it "confirms the feedback was recorded successfully" do
      request = build_ivr_request(
        query_parameters: {
          "status" => "feedback_recorded"
        }
      )
      flow = EWS1294CambodiaFlow.new(request)

      response = flow.call

      twiml = response_twiml(response_body(response))
      expect(twiml).to include(
        "Play" => "https://uploads.open-ews.org/ews_1294_cambodia/feedback_successful-khm.mp3",
        "Hangup" => nil
      )
    end

    it "handles language selection" do
      request = build_ivr_request(
        query_parameters: {
          "status" => "language_prompted"
        },
        twilio: {
          params: {
            digits: 2
          }
        }
      )
      flow = EWS1294CambodiaFlow.new(request)

      response = flow.call

      twiml = response_twiml(response_body(response))
      expect(twiml.fetch("Gather")).to include(
        "action" => "/ivr_flows/ews_1294_cambodia?language=cmo&status=province_prompted",
        "Play"=> "https://uploads.open-ews.org/ews_1294_cambodia/select_province-cmo.wav"
      )
    end

    it "handles invalid language selection" do
      request = build_ivr_request(
        query_parameters: {
          "status" => "language_prompted"
        },
        twilio: {
          params: {
            digits: 99
          }
        }
      )
      flow = EWS1294CambodiaFlow.new(request)

      response = flow.call

      twiml = response_twiml(response_body(response))
      expect(twiml.fetch("Gather")).to include(
        "action" => "/ivr_flows/ews_1294_cambodia?status=language_prompted",
        "Play"=> "https://uploads.open-ews.org/ews_1294_cambodia/select_language.wav"
      )
    end

    it "handles province selection" do
      request = build_ivr_request(
        query_parameters: {
          "status" => "province_prompted",
          "language" => "cmo"
        },
        twilio: {
          params: {
            digits: 20
          }
        }
      )
      flow = EWS1294CambodiaFlow.new(request)

      response = flow.call

      twiml = response_twiml(response_body(response))
      expect(twiml.fetch("Gather")).to include(
        "action" => "/ivr_flows/ews_1294_cambodia?language=cmo&province=11&status=district_prompted",
        "Play"=> "https://uploads.open-ews.org/ews_1294_cambodia/11-cmo.wav"
      )
    end

    it "handles invalid province selection" do
      request = build_ivr_request(
        query_parameters: {
          "status" => "province_prompted",
          "language" => "khm"
        },
        twilio: {
          params: {
            digits: 100
          }
        }
      )
      flow = EWS1294CambodiaFlow.new(request)

      response = flow.call
      twiml = response_twiml(response_body(response))
      expect(twiml.fetch("Gather")).to include(
        "action" => "/ivr_flows/ews_1294_cambodia?language=khm&status=province_prompted",
        "Play"=> "https://uploads.open-ews.org/ews_1294_cambodia/select_province-khm.wav"
      )
    end

    it "handles district selection" do
      request = build_ivr_request(
        query_parameters: {
          "status" => "district_prompted",
          "language" => "cmo",
          "province" => "11"
        },
        twilio: {
          params: {
            digits: 2
          }
        }
      )
      flow = EWS1294CambodiaFlow.new(request)

      response = flow.call

      twiml = response_twiml(response_body(response))
      expect(twiml.fetch("Gather")).to include(
        "action" => "/ivr_flows/ews_1294_cambodia?district=1102&language=cmo&province=11&status=commune_prompted",
        "Play"=> "https://uploads.open-ews.org/ews_1294_cambodia/1102-cmo.wav"
      )
    end

    it "handles invalid district selection" do
      request = build_ivr_request(
        query_parameters: {
          "status" => "district_prompted",
          "language" => "cmo",
          "province" => "11"
        },
        twilio: {
          params: {
            digits: 100
          }
        }
      )
      flow = EWS1294CambodiaFlow.new(request)

      response = flow.call

      twiml = response_twiml(response_body(response))
      expect(twiml.fetch("Gather")).to include(
        "action" => "/ivr_flows/ews_1294_cambodia?language=cmo&province=11&status=district_prompted",
        "Play"=> "https://uploads.open-ews.org/ews_1294_cambodia/11-cmo.wav"
      )
    end

    it "handles commune selection" do
      request = build_ivr_request(
        query_parameters: {
          "status" => "commune_prompted",
          "language" => "cmo",
          "province" => "11",
          "district" => "1102"
        },
        twilio: {
          params: {
            digits: 3
          },
          auth_token: "6GmFR2ny48GrmlIldBTg9fG4OC6lI5W5Pn70YkADD1b"
        }
      )
      flow = EWS1294CambodiaFlow.new(
        request,
        auth_token: "6GmFR2ny48GrmlIldBTg9fG4OC6lI5W5Pn70YkADD1b",
        open_ews_client: build_fake_open_ews_client
      )

      response = flow.call

      twiml = response_twiml(response_body(response))
      expect(twiml).to include(
        "Play" => "https://uploads.open-ews.org/ews_1294_cambodia/registration_successful-cmo.wav",
        "Hangup" => nil
      )
    end

    it "creates a beneficiary" do
      request = build_ivr_request(
        query_parameters: {
          "status" => "commune_prompted",
          "language" => "cmo",
          "province" => "11",
          "district" => "1102"
        },
        twilio: {
          params: {
            digits: 3,
            from: "+855715100900"
          },
          auth_token: "6GmFR2ny48GrmlIldBTg9fG4OC6lI5W5Pn70YkADD1b"
        }
      )
      open_ews_client = build_fake_open_ews_client
      flow = EWS1294CambodiaFlow.new(
        request,
        auth_token: "6GmFR2ny48GrmlIldBTg9fG4OC6lI5W5Pn70YkADD1b",
        open_ews_client:
      )

      flow.call

      expect(open_ews_client).to have_received(:create_beneficiary).with(
        language_code: "cmo",
        iso_country_code: "KH",
        phone_number: "+855715100900",
        address: {
          iso_region_code: "KH-11",
          administrative_division_level_2_code: "1102",
          administrative_division_level_2_name: "Kaoh Nheaek",
          administrative_division_level_3_code: "110203",
          administrative_division_level_3_name: "Roya"
        }
      )
    end

    it "handles invalid commune selection" do
      request = build_ivr_request(
        query_parameters: {
          "status" => "commune_prompted",
          "language" => "cmo",
          "province" => "11",
          "district" => "1102"
        },
        twilio: {
          params: {
            digits: 100
          }
        }
      )
      flow = EWS1294CambodiaFlow.new(request)

      response = flow.call

      twiml = response_twiml(response_body(response))
      expect(twiml.fetch("Gather")).to include(
        "action" => "/ivr_flows/ews_1294_cambodia?district=1102&language=cmo&province=11&status=commune_prompted",
        "Play"=> "https://uploads.open-ews.org/ews_1294_cambodia/1102-cmo.wav"
      )
    end

    def build_ivr_request(**options)
      build_twilio_request(
        path: "/ivr_flows/ews_1294_cambodia",
        **options
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
