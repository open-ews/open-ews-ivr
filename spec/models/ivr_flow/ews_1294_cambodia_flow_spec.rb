require "spec_helper"

module IVRFlow
  RSpec.describe EWS1294CambodiaFlow do
    it "plays the introduction" do
      request = build_ivr_request
      flow = EWS1294CambodiaFlow.new(request:)

      response = flow.call

      twiml = response_twiml(response_body(response))

      expect(twiml).to include(
        "Play" => "https://s3.ap-southeast-1.amazonaws.com/audio.open-ews.org/ews_registration/introduction-khm.wav",
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
      flow = EWS1294CambodiaFlow.new(request:)

      response = flow.call

      twiml = response_twiml(response_body(response))
      expect(twiml.fetch("Gather")).to include(
        "action" => "/ivr_flows/ews_1294_cambodia?status=main_menu_prompted",
        "Play"=> "https://s3.ap-southeast-1.amazonaws.com/audio.open-ews.org/ews_registration/main_menu-khm.mp3"
      )
    end

    it "goes to the language menu" do
      request = build_ivr_request(
        query_parameters: {
          "status" => "introduction_played"
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
      flow = EWS1294CambodiaFlow.new(request:)

      response = flow.call

      twiml = response_twiml(response_body(response))
      expect(twiml.fetch("Gather")).to include(
        "action" => "/ivr_flows/ews_1294_cambodia?status=language_prompted",
        "Play"=> "https://s3.ap-southeast-1.amazonaws.com/audio.open-ews.org/ews_registration/select_language.wav"
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
      flow = EWS1294CambodiaFlow.new(request:)

      response = flow.call

      twiml = response_twiml(response_body(response))
      expect(twiml).to include(
        "Play" => "https://s3.ap-southeast-1.amazonaws.com/audio.open-ews.org/ews_registration/record_feedback_instructions-khm.mp3",
        "Record" => include(
          "action" => "/ivr_flows/ews_1294_cambodia?status=feedback_recorded",
          "recordingStatusCallback" => "https://ivr.open-ews.org/ivr_flows/ews_1294_cambodia/feedback"
        )
      )
    end

    it "confirms the feedback was recorded successfully" do
      request = build_ivr_request(
        query_parameters: {
          "status" => "feedback_recorded"
        }
      )
      flow = EWS1294CambodiaFlow.new(request:)

      response = flow.call

      twiml = response_twiml(response_body(response))
      expect(twiml).to include(
        "Play" => "https://s3.ap-southeast-1.amazonaws.com/audio.open-ews.org/ews_registration/feedback_successful-khm.mp3",
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
      flow = EWS1294CambodiaFlow.new(request:)

      response = flow.call

      twiml = response_twiml(response_body(response))
      expect(twiml.fetch("Gather")).to include(
        "action" => "/ivr_flows/ews_1294_cambodia?language=cmo&status=province_prompted",
        "Play"=> "https://s3.ap-southeast-1.amazonaws.com/audio.open-ews.org/ews_registration/select_province-cmo.wav"
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
      flow = EWS1294CambodiaFlow.new(request:)

      response = flow.call

      twiml = response_twiml(response_body(response))
      expect(twiml.fetch("Gather")).to include(
        "action" => "/ivr_flows/ews_1294_cambodia?language=cmo&province=11&status=district_prompted",
        "Play"=> "https://s3.ap-southeast-1.amazonaws.com/audio.open-ews.org/ews_registration/11-cmo.wav"
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
      flow = EWS1294CambodiaFlow.new(request:)

      response = flow.call
      twiml = response_twiml(response_body(response))
      expect(twiml.fetch("Gather")).to include(
        "action" => "/ivr_flows/ews_1294_cambodia?language=khm&status=province_prompted",
        "Play"=> "https://s3.ap-southeast-1.amazonaws.com/audio.open-ews.org/ews_registration/select_province-khm.wav"
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
      flow = EWS1294CambodiaFlow.new(request:)

      response = flow.call

      twiml = response_twiml(response_body(response))
      expect(twiml.fetch("Gather")).to include(
        "action" => "/ivr_flows/ews_1294_cambodia?language=cmo&province=11&district=1102&status=commune_prompted",
        "Play"=> "https://s3.ap-southeast-1.amazonaws.com/audio.open-ews.org/ews_registration/1102-cmo.wav"
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
      flow = EWS1294CambodiaFlow.new(request:)

      response = flow.call

      twiml = response_twiml(response_body(response))
      expect(twiml.fetch("Gather")).to include(
        "action" => "/ivr_flows/ews_1294_cambodia?language=cmo&province=11&status=district_prompted",
        "Play"=> "https://s3.ap-southeast-1.amazonaws.com/audio.open-ews.org/ews_registration/11-cmo.wav"
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
      flow = EWS1294CambodiaFlow.new(request:, auth_token: "6GmFR2ny48GrmlIldBTg9fG4OC6lI5W5Pn70YkADD1b")
      response = flow.call

      twiml = response_twiml(response_body(response))
      expect(twiml).to include(
        "Play" => "https://s3.ap-southeast-1.amazonaws.com/audio.open-ews.org/ews_registration/registration_successful-cmo.wav",
        "Hangup" => nil
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
      flow = EWS1294CambodiaFlow.new(request:)

      response = flow.call

      twiml = response_twiml(response_body(response))
      expect(twiml.fetch("Gather")).to include(
        "action" => "/ivr_flows/ews_1294_cambodia?language=cmo&province=11&district=1102&status=commune_prompted",
        "Play"=> "https://s3.ap-southeast-1.amazonaws.com/audio.open-ews.org/ews_registration/1102-cmo.wav"
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

    # build_request_body(
    #   call_sid: delivery_attempt.remote_call_id,
    #   account_sid: account.twilio_account_sid,
    #   direction: "outbound-api",
    #   call_status: "completed",
    #   from: "1294",
    #   to: delivery_attempt.phone_number,
    #   call_duration: "87"
    # )

    # def build_request_body(options)
    #   {
    #     CallSid: options.fetch(:call_sid) { SecureRandom.uuid },
    #     From: options.fetch(:from) { "+85510202101" },
    #     To: options.fetch(:to) { "1294" },
    #     Direction: options.fetch(:direction) { "inbound" },
    #     CallStatus: options.fetch(:call_status) { "ringing" },
    #     AccountSid: options.fetch(:account_sid),
    #     CallDuration: options.fetch(:call_duration) { nil },
    #     ApiVersion: options.fetch(:api_version) { "2010-04-01" }
    #   }.compact
    # end
  end
end

# it "Creates a phone call event for an outbound call" do
#   account = create(:account, :with_twilio_provider)
#   delivery_attempt = create_delivery_attempt(:remotely_queued, account:)

#   request_body = build_request_body(
#     call_sid: delivery_attempt.remote_call_id,
#     account_sid: account.twilio_account_sid,
#     direction: "outbound-api",
#     call_status: "completed",
#     from: "1294",
#     to: delivery_attempt.phone_number,
#     call_duration: "87"
#   )

#   perform_enqueued_jobs do
#     post(
#       twilio_webhooks_phone_call_events_url,
#       params: request_body,
#       headers: build_twilio_signature(
#         auth_token: account.twilio_auth_token,
#         url: twilio_webhooks_phone_call_events_url,
#         request_body: request_body
#       )
#     )
#   end

#   expect(response.code).to eq("201")
#   created_event = RemotePhoneCallEvent.last!
#   expect(created_event).to have_attributes(
#     call_duration: 87,
#     delivery_attempt: have_attributes(
#       status: "completed",
#       call_flow_logic: CallFlowLogic::HelloWorld.to_s,
#       remote_status: request_body.fetch(:CallStatus),
#       duration: 87
#     )
#   )
#   expect(response.body).to eq(CallFlowLogic::HelloWorld.new.to_xml)
# end
