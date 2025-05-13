require "spec_helper"

module IVRFlow
  RSpec.describe EWS1939LaosFlow do
    it "plays the introduction and goes to the province selection menu" do
      request = build_ivr_request
      flow = EWS1939LaosFlow.new(request)

      response = flow.call

      twiml = response_twiml(response_body(response))
      expect(twiml).to include(
        "Play" => "https://uploads.open-ews.org/ews_1939_laos/introduction-lao.mp3",
        "Gather" => include(
          "action" => "/ivr_flows/ews_1939_laos?status=province_prompted",
          "Play" => "https://uploads.open-ews.org/ews_1939_laos/select_province-lao.mp3"
        )
      )
    end

    it "handles province selection" do
      request = build_ivr_request(
        query_parameters: {
          "status" => "province_prompted"
        },
        twilio: {
          params: {
            digits: "2"
          }
        }
      )
      flow = EWS1939LaosFlow.new(request)

      response = flow.call

      twiml = response_twiml(response_body(response))
      expect(twiml.fetch("Gather")).to include(
        "action" => "/ivr_flows/ews_1939_laos?province=16&status=district_prompted",
        "Play" => "https://uploads.open-ews.org/ews_1939_laos/16-lao.mp3"
      )
    end

    it "handles invalid province selection" do
      request = build_ivr_request(
        query_parameters: {
          "status" => "province_prompted"
        },
        twilio: {
          params: {
            digits: "99"
          }
        }
      )
      flow = EWS1939LaosFlow.new(request)

      response = flow.call

      twiml = response_twiml(response_body(response))
      expect(twiml.fetch("Gather")).to include(
        "action" => "/ivr_flows/ews_1939_laos?status=province_prompted",
        "Play" => "https://uploads.open-ews.org/ews_1939_laos/select_province-lao.mp3"
      )
    end

    it "handles district selection" do
      request = build_ivr_request(
        query_parameters: {
          "status" => "district_prompted",
          "province" => "16"
        },
        twilio: {
          params: {
            digits: "1"
          },
          auth_token: "6GmFR2ny48GrmlIldBTg9fG4OC6lI5W5Pn70YkADD1b"
        }
      )
      flow = EWS1939LaosFlow.new(
        request,
        auth_token: "6GmFR2ny48GrmlIldBTg9fG4OC6lI5W5Pn70YkADD1b",
        open_ews_client: build_fake_open_ews_client
      )

      response = flow.call

      twiml = response_twiml(response_body(response))
      expect(twiml).to include(
        "Play" => "https://uploads.open-ews.org/ews_1939_laos/registration_successful-lao.mp3",
        "Hangup" => nil
      )
    end

    it "creates a beneficiary" do
      request = build_ivr_request(
        query_parameters: {
          "status" => "district_prompted",
          "province" => "16",
        },
        twilio: {
          params: {
            digits: "1",
            from: "+855715100900"
          },
          auth_token: "6GmFR2ny48GrmlIldBTg9fG4OC6lI5W5Pn70YkADD1b"
        }
      )
      open_ews_client = build_fake_open_ews_client
      flow = EWS1939LaosFlow.new(
        request,
        auth_token: "6GmFR2ny48GrmlIldBTg9fG4OC6lI5W5Pn70YkADD1b",
        open_ews_client:
      )

      flow.call

      expect(open_ews_client).to have_received(:create_beneficiary).with(
        iso_language_code: "lao",
        iso_country_code: "LA",
        phone_number: "+855715100900",
        metadata: {
          created_by: {
            ivr_flow: "IVRFlow::EWS1939LaosFlow",
            source: AppSettings.fetch(:app_source),
            version: AppSettings.fetch(:app_version),
            environment: AppSettings.env
          }
        },
        address: {
          iso_region_code: "LA-CH",
          administrative_division_level_2_code: "1601",
          administrative_division_level_2_name: "Pakse"
        }
      )
    end

    it "handles invalid district selection" do
      request = build_ivr_request(
        query_parameters: {
          "status" => "district_prompted",
          "province" => "16"
        },
        twilio: {
          params: {
            digits: "100"
          }
        }
      )
      flow = EWS1939LaosFlow.new(request)

      response = flow.call

      twiml = response_twiml(response_body(response))
      expect(twiml.fetch("Gather")).to include(
        "action" => "/ivr_flows/ews_1939_laos?province=16&status=district_prompted",
        "Play" => "https://uploads.open-ews.org/ews_1939_laos/16-lao.mp3"
      )
    end

    it "handles starting over from district menu" do
      request = build_ivr_request(
        query_parameters: {
          "status" => "district_prompted",
          "province" => "16"
        },
        twilio: {
          params: {
            digits: "*"
          }
        }
      )
      flow = EWS1939LaosFlow.new(request)

      response = flow.call

      twiml = response_twiml(response_body(response))
      expect(twiml.fetch("Gather")).to include(
        "action" => "/ivr_flows/ews_1939_laos?status=province_prompted",
        "Play" => "https://uploads.open-ews.org/ews_1939_laos/select_province-lao.mp3"
      )
    end

    def build_ivr_request(**options)
      build_twilio_request(
        path: "/ivr_flows/ews_1939_laos",
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
