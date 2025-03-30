require_relative "menu"

module IVRFlow
  class EWS1294CambodiaFlow
    AUDIO_NAMESPACE = "ews_1294_cambodia".freeze
    ISO_COUNTRY_CODE = "KH".freeze

    class LanguageMenu < IVRFlow::Menu
      # https://en.wikipedia.org/wiki/ISO_639-3
      # Khmer         | https://iso639-3.sil.org/code/khm | https://en.wikipedia.org/wiki/Khmer_language
      # Central Mnong | https://iso639-3.sil.org/code/cmo | https://en.wikipedia.org/wiki/Mnong_language
      # Jarai         | https://iso639-3.sil.org/code/jra | https://en.wikipedia.org/wiki/Jarai_language
      # Tampuan       | https://iso639-3.sil.org/code/tpu | https://en.wikipedia.org/wiki/Tampuan_language
      # Krung         | https://iso639-3.sil.org/code/krr | https://en.wikipedia.org/wiki/Brao_language

      Language = Data.define(:id, :name)

      CHOICES = [
        Language.new(id: "khm", name: "Khmer"),
        Language.new(id: "cmo", name: "Central Mnong"),
        Language.new(id: "jra", name: "Jarai"),
        Language.new(id: "tpu", name: "Tampuan"),
        Language.new(id: "krr", name: "Krung")
      ].freeze

      def valid_choice?
        (1..CHOICES.size).member?(request.twilio.digits)
      end

      def selection
        CHOICES[request.twilio.digits - 1] if valid_choice?
      end
    end

    class MainMenu < IVRFlow::Menu
      FEEDBACK_FEATURE_FLAG_PHONE_NUMBERS = [
        "+855715100860", "+85570753999", "+855966164166", "+85592943196", "+855965636025",
        "+85578746371", "+85512716884", "+855966946549", "+85511765511"
      ].freeze

      def leave_feedback?
        request.twilio.digits == 2
      end

      def feedback_enabled?
        FEEDBACK_FEATURE_FLAG_PHONE_NUMBERS.include?(request.twilio.beneficiary)
      end
    end

    class ProvinceMenu < IVRFlow::Menu
      class Province
        attr_reader :id, :available_languages

        def initialize(id:, available_languages: [ "khm" ], **)
          @id = id
          @available_languages = available_languages
        end
      end

      attr_reader :language

      def initialize(request, language:)
        super(request)
        @language = language
      end

      MENU = [
        Province.new(id: "15", name: "Pursat"),
        Province.new(id: "01", name: "Banteay Meanchey"),
        Province.new(id: "06", name: "Kampong Thom"),
        Province.new(id: "07", name: "Kampot"),
        Province.new(id: "04", name: "Kampong Chhnang"),
        Province.new(id: "17", name: "Siem Reap"),
        Province.new(id: "02", name: "Battambang"),
        Province.new(id: "10", name: "Kratie"),
        Province.new(id: "19", name: "Steung Treng"),
        Province.new(id: "13", name: "Preah Vihear"),
        Province.new(id: "22", name: "Oddar Meanchey"),
        Province.new(id: "23", name: "Kep"),
        Province.new(id: "24", name: "Pailin"),
        Province.new(id: "09", name: "Koh Kong"),
        Province.new(id: "18", name: "Preah Sihanouk"),
        Province.new(id: "03", name: "Kampong Cham"),
        Province.new(id: "25", name: "Tboung Khmum"),
        Province.new(id: "14", name: "Prey Veng"),
        Province.new(id: "16", name: "Ratanakkiri", available_languages: %w[khm jra tpu krr]),
        Province.new(id: "11", name: "Mondulkiri", available_languages: %w[khm cmo]),
        Province.new(id: "20", name: "Svay Rieng"),
        Province.new(id: "05", name: "Kampong Speu"),
        Province.new(id: "21", name: "Takao"),
        Province.new(id: "08", name: "Kandal"),
        Province.new(id: "12", name: "Phnom Penh")
      ].freeze

      def valid_choice?
        choices.include?(request.twilio.digits)
      end

      def selection
        MENU[request.twilio.digits - 1] if valid_choice?
      end

      private

      def choices
        @choices ||= MENU.each_with_object([]).with_index do |(province, result), index|
          result << (index + 1) if province.available_languages.include?(language)
        end
      end
    end

    class DistrictMenu < IVRFlow::Menu
      attr_reader :language, :province

      def initialize(request, language:, province:)
        super(request)
        @language = language
        @province = province
      end

      def valid_choice?
        (1..districts.size).member?(request.twilio.digits)
      end

      def selection
        districts[request.twilio.digits - 1] if valid_choice?
      end

      private

      def districts
        @districts ||= Pumi::District.where(province_id: province).sort_by(&:id)
      end
    end

    class CommuneMenu < IVRFlow::Menu
      attr_reader :language, :district

      def initialize(request, language:, district:)
        super(request)
        @language = language
        @district = district
      end

      def valid_choice?
        (1..communes.size).member?(request.twilio.digits)
      end

      def selection
        communes[request.twilio.digits - 1] if valid_choice?
      end

      private

      def communes
        @communes ||= Pumi::Commune.where(district_id: district).sort_by(&:id)
      end
    end

    attr_reader :request, :open_ews_client

    def initialize(request, **options)
      @request = request
      @open_ews_client = options.fetch(:open_ews_client) { OpenEWS::Client.new(api_key: options.fetch(:open_ews_api_key) { AppSettings.dig("open_ews_accounts", "ews_1294_cambodia", "api_key") }) }
      @auth_token = options.fetch(:auth_token) { -> { open_ews_client.fetch_account_settings.somleng_auth_token } }
    end

    def call
      twiml = case status
      when "answered"
        Twilio::TwiML::VoiceResponse.new do |response|
          response.play(url: build_audio_url(filename: :introduction, language: "khm"))
          response.redirect(build_redirect_url(status: :introduction_played))
        end
      when "introduction_played"
        if main_menu.feedback_enabled?
          prompt(action: build_redirect_url(status: :main_menu_prompted), audio_url: build_audio_url(filename: :main_menu, language: "khm", file_extension: "mp3"))
        else
          prompt_language
        end
      when "main_menu_prompted"
        if main_menu.leave_feedback?
          Twilio::TwiML::VoiceResponse.new do |response|
            response.play(url: build_audio_url(filename: :record_feedback_instructions, language: "khm", file_extension: "mp3"))
            response.record(action: build_redirect_url(status: :feedback_recorded))
          end
        else
          prompt_language
        end
      when "feedback_recorded"
        Twilio::TwiML::VoiceResponse.new do |response|
          response.play(url: build_audio_url(filename: :feedback_successful, language: "khm", file_extension: "mp3"))
          response.hangup
        end
      when "language_prompted"
        if language_menu.valid_choice?
          @language = language_menu.selection.id
          prompt_province
        else
          prompt_language
        end
      when "province_prompted"
        if province_menu.valid_choice?
          @province = province_menu.selection.id
          prompt_district
        else
          prompt_province
        end
      when "district_prompted"
        if district_menu.valid_choice?
          @district = district_menu.selection.id
          prompt_commune
        else
          prompt_district
        end
      when "commune_prompted"
        if commune_menu.valid_choice?
          commune = commune_menu.selection

          ValidateTwilioRequest.call(request:, auth_token:)
          CreateBeneficiary.call(
            open_ews_client:,
            iso_country_code: ISO_COUNTRY_CODE,
            phone_number: request.twilio.beneficiary,
            language_code: language,
            address: {
              iso_region_code: commune.province.iso3166_2,
              administrative_division_level_2_code: commune.district.id,
              administrative_division_level_2_name: commune.district.name_en,
              administrative_division_level_3_code: commune.id,
              administrative_division_level_3_name: commune.name_en
            }
          )

          Twilio::TwiML::VoiceResponse.new do |response|
            response.play(url: build_audio_url(filename: :registration_successful, language:))
            response.hangup
          end
        else
          prompt_commune
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

    def main_menu
      @main_menu ||= MainMenu.new(request)
    end

    def language_menu
      @language_menu ||= LanguageMenu.new(request)
    end

    def province_menu
      @province_menu ||= ProvinceMenu.new(request, language:)
    end

    def district_menu
      @district_menu ||= DistrictMenu.new(request, language:, province:)
    end

    def commune_menu
      @commune_menu ||= CommuneMenu.new(request, language:, district:)
    end

    def language
      @language ||= request.query_parameters["language"]
    end

    def province
      @province ||= request.query_parameters["province"]
    end

    def district
      @district ||= request.query_parameters["district"]
    end

    def prompt_language
      prompt(action: build_redirect_url(status: :language_prompted), audio_url: build_audio_url(filename: :select_language))
    end

    def prompt_province
      prompt(action: build_redirect_url(status: :province_prompted), audio_url: build_audio_url(filename: :select_province, language:))
    end

    def prompt_district
      prompt(action: build_redirect_url(status: :district_prompted), audio_url: build_audio_url(filename: province, language:))
    end

    def prompt_commune
      prompt(action: build_redirect_url(status: :commune_prompted), audio_url: build_audio_url(filename: district, language:))
    end

    def build_audio_url(**)
      AudioURL.new(namespace: AUDIO_NAMESPACE, **).url
    end

    def build_redirect_url(**params)
      uri = URI(request.path)
      uri.query = URI.encode_www_form({ language:, province:, district:, **params }.transform_keys(&:to_sym).compact.sort.to_h)
      uri.to_s
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
