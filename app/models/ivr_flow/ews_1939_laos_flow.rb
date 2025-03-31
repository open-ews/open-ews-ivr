module IVRFlow
  class EWS1939LaosFlow
    AUDIO_NAMESPACE = "ews_1939_laos".freeze
    ISO_COUNTRY_CODE = "LA".freeze

    class ProvinceMenu < Menu
      Province = Data.define(:id, :name)

      MENU = [
        Province.new(id: "14", name: "Salavan"),
        Province.new(id: "16", name: "Champasak"),
        Province.new(id: "17", name: "Attapeu")
      ]

      def valid_choice?
        (1..MENU.size).member?(response.choice)
      end

      def selection
        MENU[response.choice - 1] if valid_choice?
      end
    end

    class DistrictMenu < IVRFlow::Menu
      attr_reader :province

      def initialize(response, province_id:)
        super(response)
        @province = PumiLao::Province.find_by!(id: province_id)
      end

      def valid_choice?
        (1..districts.size).member?(response.choice)
      end

      def selection
        districts[response.choice - 1] if valid_choice?
      end

      private

      def districts
        @districts ||= PumiLao::District.where(province:).sort_by(&:id)
      end
    end

    attr_reader :request, :open_ews_client, :app_context, :twiml_builder

    def initialize(request, **options)
      @request = request
      @open_ews_client = options.fetch(:open_ews_client) { OpenEWS::Client.new(api_key: options.fetch(:open_ews_api_key) { AppSettings.dig("open_ews_accounts", "ews_1939_laos", "api_key") }) }
      @auth_token = options.fetch(:auth_token) { -> { open_ews_client.fetch_account_settings.somleng_auth_token } }
      @app_context = options.fetch(:app_context) { AppContext.new }
      @twiml_builder = options.fetch(:twiml_builder) { TwiMLBuilder.new }
    end

    def call
      twiml = case status
      when "answered"
        prompt_province(before: ->(response) { response.play(url: build_audio_url(filename: :introduction)) })
      when "province_prompted"
        if province_menu.valid_choice?
          @province = province_menu.selection.id
          prompt_district
        else
          prompt_province
        end
      when "district_prompted"
        if district_menu.valid_choice?
          district = district_menu.selection

          ValidateTwilioRequest.call(request:, auth_token:)
          CreateBeneficiary.call(
            open_ews_client:,
            iso_country_code: ISO_COUNTRY_CODE,
            phone_number: request.twilio.beneficiary,
            language_code: "lao",
            metadata: {
              created_by: app_context.as_json.merge(ivr_flow: self.class.name)
            },
            address: {
              iso_region_code: district.province.iso3166_2,
              administrative_division_level_2_code: district.id,
              administrative_division_level_2_name: district.name_en
            }
          )

          twiml_builder.hangup(before: ->(response) { response.play(url: build_audio_url(filename: :registration_successful)) })
        elsif district_menu.response.start_over?
          prompt_province
        else
          prompt_district
        end
      end

      TwiMLResponse.new(twiml: twiml.to_s)
    end

    private

    def status
      request.query_parameters.fetch("status", "answered")
    end

    def auth_token
      @auth_token.respond_to?(:call) ? @auth_token.call : @auth_token
    end

    def build_audio_url(**options)
      AudioURL.new(namespace: AUDIO_NAMESPACE, file_extension: "mp3", language: "lao", **options).url
    end

    def build_redirect_url(**params)
      uri = URI(request.path)
      uri.query = URI.encode_www_form(params.transform_keys(&:to_sym).compact.sort.to_h)
      uri.to_s
    end

    def prompt_province(**)
      prompt(
        action: build_redirect_url(status: :province_prompted),
        audio_url: build_audio_url(filename: :select_province),
        **
      )
    end

    def prompt_district
      prompt(
        action: build_redirect_url(status: :district_prompted, province:),
        audio_url: build_audio_url(filename: province)
      )
    end

    def menu_response
      @menu_response ||= MenuResponse.new(request)
    end

    def province_menu
      @province_menu ||= ProvinceMenu.new(menu_response)
    end

    def district_menu
      @district_menu ||= DistrictMenu.new(menu_response, province_id: province)
    end

    def province
      @province ||= request.query_parameters["province"]
    end

    def prompt(...)
      twiml_builder.prompt(...)
    end
  end
end
