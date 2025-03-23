require_relative "menu"

module IVRFlow
  class EWS1294CambodiaFlow < Base
    AUDIO_NAMESPACE = "ews_registration".freeze

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
      def leave_feedback?
        request.twilio.digits == 2
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

      def initialize(language:, **)
        @language = language
        super(**)
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

      def initialize(language:, province:, **)
        @language = language
        @province = province
        super(**)
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

      def initialize(language:, district:, **)
        @language = language
        @district = district
        super(**)
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

    FEEDBACK_FEATURE_FLAG_PHONE_NUMBERS = [
      "+855715100860", "+85570753999", "+855966164166", "+85592943196", "+855965636025",
      "+85578746371", "+85512716884", "+855966946549", "+85511765511"
    ].freeze

    def call
      twiml = case status
      when "answered"
        Twilio::TwiML::VoiceResponse.new do |response|
          response.play(url: build_audio_url(filename: :introduction, language: "khm"))
          response.redirect(build_redirect_url(status: :introduction_played))
        end
      when "introduction_played"
        if feedback_enabled?
          main_menu.prompt(action: build_redirect_url(status: :main_menu_prompted), audio_url: build_audio_url(filename: :main_menu, language: "khm", file_extension: "mp3"))
        else
          prompt_language
        end
      when "main_menu_prompted"
        if main_menu.leave_feedback?
          Twilio::TwiML::VoiceResponse.new do |response|
            response.play(url: build_audio_url(filename: :record_feedback_instructions, language: "khm", file_extension: "mp3"))
            response.record(action: build_redirect_url(status: :feedback_recorded), recording_status_callback: Router.url_for(path: "/ivr_flows/ews_1294_cambodia/feedback", host: request.host, scheme: request.scheme))
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
          @commune = commune_menu.selection.id
          # twilio_request_validator.validate_request(request.twilio.signature)
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

    def main_menu
      @main_menu ||= MainMenu.new(request:)
    end

    def language_menu
      @language_menu ||= LanguageMenu.new(request:)
    end

    def province_menu
      @province_menu ||= ProvinceMenu.new(request:, language:)
    end

    def district_menu
      @district_menu ||= DistrictMenu.new(request:, language:, province:)
    end

    def commune_menu
      @commune_menu ||= CommuneMenu.new(request:, language:, district:)
    end

    def prompt_language
      language_menu.prompt(action: build_redirect_url(status: :language_prompted), audio_url: build_audio_url(filename: :select_language))
    end

    def prompt_province
      province_menu.prompt(action: build_redirect_url(status: :province_prompted), audio_url: build_audio_url(filename: :select_province, language:))
    end

    def prompt_district
      district_menu.prompt(action: build_redirect_url(status: :district_prompted), audio_url: build_audio_url(filename: province, language:))
    end

    def prompt_commune
      commune_menu.prompt(action: build_redirect_url(status: :commune_prompted), audio_url: build_audio_url(filename: district, language:))
    end

    def build_redirect_url(**params)
      super(
        **{
          "language" => language,
          "province" => province,
          "district" => district,
          **params
        }.compact
      )
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

    def build_audio_url(**)
      super(namespace: AUDIO_NAMESPACE, **)
    end

    def feedback_enabled?
      FEEDBACK_FEATURE_FLAG_PHONE_NUMBERS.include?(request.twilio.from)
    end
  end
end

# class EWSRegistration < Base
#   Language = Struct.new(:code, :name, :links, keyword_init: true)
#   FEEDBACK_FEATURE_FLAG_PHONE_NUMBERS = [
#     "855715100860", "85570753999", "855966164166", "85592943196", "855965636025",
#     "85578746371", "85512716884", "855966946549", "85511765511"
#   ].freeze

#   # https://en.wikipedia.org/wiki/ISO_639-3
#   LANGUAGE_MENU = [
#     Language.new(
#       code: "khm", name: "Khmer",
#       links: [ "https://iso639-3.sil.org/code/khm", "https://en.wikipedia.org/wiki/Khmer_language" ]
#     ),
#     Language.new(
#       code: "cmo", name: "Central Mnong",
#       links: [ "https://iso639-3.sil.org/code/cmo", "https://en.wikipedia.org/wiki/Mnong_language" ]
#     ),
#     Language.new(
#       code: "jra", name: "Jarai",
#       links: [ "https://iso639-3.sil.org/code/jra", "https://en.wikipedia.org/wiki/Jarai_language" ]
#     ),
#     Language.new(
#       code: "tpu", name: "Tampuan",
#       links: [ "https://iso639-3.sil.org/code/tpu", "https://en.wikipedia.org/wiki/Tampuan_language" ]
#     ),
#     Language.new(
#       code: "krr", name: "Krung",
#       links: [ "https://iso639-3.sil.org/code/krr", "https://en.wikipedia.org/wiki/Brao_language" ]
#     )
#   ].freeze

#   Province = Struct.new(:code, :name, :available_languages, keyword_init: true) do
#     def initialize(options)
#       super(options.reverse_merge(available_languages: [ "khm" ]))
#     end
#   end

#   # http://db.ncdd.gov.kh/gazetteer/view/index.castle
#   PROVINCE_MENU = [
#     Province.new(code: "15", name: "Pursat"),
#     Province.new(code: "01", name: "Banteay Meanchey"),
#     Province.new(code: "06", name: "Kampong Thom"),
#     Province.new(code: "07", name: "Kampot"),
#     Province.new(code: "04", name: "Kampong Chhnang"),
#     Province.new(code: "17", name: "Siem Reap"),
#     Province.new(code: "02", name: "Battambang"),
#     Province.new(code: "10", name: "Kratie"),
#     Province.new(code: "19", name: "Steung Treng"),
#     Province.new(code: "13", name: "Preah Vihear"),
#     Province.new(code: "22", name: "Oddar Meanchey"),
#     Province.new(code: "23", name: "Kep"),
#     Province.new(code: "24", name: "Pailin"),
#     Province.new(code: "09", name: "Koh Kong"),
#     Province.new(code: "18", name: "Preah Sihanouk"),
#     Province.new(code: "03", name: "Kampong Cham"),
#     Province.new(code: "25", name: "Tboung Khmum"),
#     Province.new(code: "14", name: "Prey Veng"),
#     Province.new(code: "16", name: "Ratanakkiri", available_languages: %w[khm jra tpu krr]),
#     Province.new(code: "11", name: "Mondulkiri", available_languages: %w[khm cmo]),
#     Province.new(code: "20", name: "Svay Rieng"),
#     Province.new(code: "05", name: "Kampong Speu"),
#     Province.new(code: "21", name: "Takao"),
#     Province.new(code: "08", name: "Kandal"),
#     Province.new(code: "12", name: "Phnom Penh")
#   ].freeze

#   INITIAL_STATUS = :answered

#   attr_reader :voice_response

#   include AASM

#   aasm(column: :status, whiny_transitions: false) do
#     state INITIAL_STATUS, initial: true
#     state :playing_introduction
#     state :main_menu
#     state :recording_feedback
#     state :playing_feedback_successful
#     state :gathering_language
#     state :gathering_province
#     state :gathering_district
#     state :gathering_commune
#     state :playing_conclusion
#     state :finished

#     before_all_events :read_status, :initialize_voice_response
#     after_all_events :persist_status

#     event :process_call do
#       transitions from: :answered,
#                   to: :playing_introduction,
#                   after: :play_introduction

#       transitions from: :playing_introduction,
#                   to: :main_menu,
#                   if: :feedback_enabled?,
#                   after: :prompt_main_menu

#       transitions from: :playing_introduction,
#                   to: :gathering_language,
#                   after: :gather_language

#       transitions from: :main_menu,
#                   to: :gathering_language,
#                   if: :register?,
#                   after: :gather_language

#       transitions from: :main_menu,
#                   to: :recording_feedback,
#                   if: :record_feedback?,
#                   after: :record_feedback

#       transitions from: :recording_feedback,
#                   to: :playing_feedback_successful,
#                   after: :play_feedback_successful

#       transitions from: :playing_feedback_successful,
#                   to: :finished,
#                   after: :hangup

#       transitions from: :gathering_language,
#                   to: :gathering_province,
#                   if: :language_gathered?,
#                   after: %i[persist_language gather_province]

#       transitions from: :gathering_province,
#                   to: :gathering_district,
#                   if: :province_gathered?,
#                   after: %i[persist_province gather_district]

#       transitions from: :gathering_district,
#                   to: :gathering_commune,
#                   if: :district_gathered?,
#                   after: %i[persist_district gather_commune]

#       transitions from: :gathering_commune,
#                   to: :playing_conclusion,
#                   if: :commune_gathered?,
#                   after: %i[persist_commune update_beneficiary play_conclusion]

#       transitions from: %i[gathering_province gathering_district gathering_commune],
#                   to: :gathering_language,
#                   if: :start_over?,
#                   after: %i[gather_language]

#       transitions from: :playing_conclusion,
#                   to: :finished,
#                   after: :hangup
#     end
#   end

#   def run!
#     ApplicationRecord.transaction do
#       super
#       process_call
#     end
#   end

#   def to_xml(_options = {})
#     voice_response.to_s
#   end

#   private

#   def read_status
#     aasm.current_state = delivery_attempt.metadata.fetch("status", INITIAL_STATUS).to_sym
#   end

#   def initialize_voice_response
#     case aasm.current_state
#     when :main_menu
#       prompt_main_menu
#     when :gathering_language
#       gather_language
#     when :gathering_province
#       gather_province
#     when :gathering_district
#       gather_district
#     when :gathering_commune
#       gather_commune
#     end
#   end

#   def persist_status
#     update_delivery_attempt!(status: aasm.to_state)
#   end

#   def play_introduction
#     @voice_response = Twilio::TwiML::VoiceResponse.new do |response|
#       play(:introduction, response, language_code: "khm")
#       response.redirect(current_url)
#     end
#   end

#   def prompt_main_menu
#     @voice_response = gather do |response|
#       play(:main_menu, response, language_code: "khm", file_extension: "mp3")
#     end
#   end

#   def record_feedback
#     @voice_response = Twilio::TwiML::VoiceResponse.new do |response|
#       play(:record_feedback_instructions, response, language_code: "khm", file_extension: "mp3")
#       response.record(recording_status_callback: url_helpers.twilio_webhooks_recording_status_callbacks_url)
#     end
#   end

#   def gather_language
#     @voice_response = gather do |response|
#       play(:select_language, response)
#     end
#   end

#   def gather_province
#     @voice_response = gather do |response|
#       play(
#         :select_province,
#         response,
#         language_code: delivery_attempt_metadata(:language_code)
#       )
#     end
#   end

#   def gather_district
#     @voice_response = gather do |response|
#       play(
#         delivery_attempt_metadata(:province_code),
#         response,
#         language_code: delivery_attempt_metadata(:language_code)
#       )
#     end
#   end

#   def gather_commune
#     @voice_response = gather do |response|
#       play(
#         delivery_attempt_metadata(:district_code),
#         response,
#         language_code: delivery_attempt_metadata(:language_code)
#       )
#     end
#   end

#   def play_feedback_successful
#     @voice_response = Twilio::TwiML::VoiceResponse.new do |response|
#       play(:feedback_successful, response, language_code: :khm, file_extension: "mp3")
#       response.redirect(current_url)
#     end
#   end

#   def play_conclusion
#     @voice_response = Twilio::TwiML::VoiceResponse.new do |response|
#       play(:registration_successful, response, language_code: delivery_attempt_metadata(:language_code))
#       response.redirect(current_url)
#     end
#   end

#   def gather(&_block)
#     Twilio::TwiML::VoiceResponse.new do |response|
#       response.gather(action_on_empty_result: true) do |gather|
#         yield(gather)
#       end
#     end
#   end

#   def play(filename, response, language_code: nil, file_extension: "wav")
#     key = [ "ews_registration/#{filename}", language_code ].compact.join("-")
#     response.play(url: AudioURL.new(key: "#{key}.#{file_extension}").url)
#   end

#   def hangup
#     @voice_response = Twilio::TwiML::VoiceResponse.new(&:hangup)
#   end

#   def start_over?
#     dtmf_tones.to_s.first == "*"
#   end

#   def register?
#     dtmf_tones.blank? || pressed_digits == 1
#   end

#   def record_feedback?
#     pressed_digits == 2
#   end

#   def feedback_enabled?
#     FEEDBACK_FEATURE_FLAG_PHONE_NUMBERS.include?(delivery_attempt.beneficiary.phone_number)
#   end

#   def language_gathered?
#     selected_language.present?
#   end

#   def province_gathered?
#     selected_province.present?
#   end

#   def district_gathered?
#     selected_district.present?
#   end

#   def commune_gathered?
#     selected_commune.present?
#   end

#   def selected_language
#     return if pressed_digits.zero?

#     LANGUAGE_MENU[pressed_digits - 1]
#   end

#   def selected_province
#     return if pressed_digits.zero?

#     province = PROVINCE_MENU[pressed_digits - 1]
#     return if province.blank?
#     return if province.available_languages.exclude?(delivery_attempt_metadata(:language_code))

#     Pumi::Province.find_by_id(province.code)
#   end

#   def selected_district
#     return if pressed_digits.zero?

#     province_code = delivery_attempt_metadata(:province_code)
#     districts = Pumi::District.where(province_id: province_code).sort_by(&:id)
#     districts[pressed_digits - 1]
#   end

#   def selected_commune
#     return if pressed_digits.zero?

#     district_code = delivery_attempt_metadata(:district_code)
#     communes = Pumi::Commune.where(district_id: district_code).sort_by(&:id)
#     communes[pressed_digits - 1]
#   end

#   def persist_language
#     update_delivery_attempt!(
#       language_code: selected_language.code
#     )
#   end

#   def persist_province
#     update_delivery_attempt!(
#       province_code: selected_province.id,
#       province_name_en: selected_province.name_en
#     )
#   end

#   def persist_district
#     update_delivery_attempt!(
#       district_code: selected_district.id,
#       district_name_en: selected_district.name_en
#     )
#   end

#   def persist_commune
#     update_delivery_attempt!(
#       commune_code: selected_commune.id,
#       commune_name_en: selected_commune.name_en
#     )
#   end

#   def update_beneficiary
#     beneficiary = delivery_attempt.beneficiary
#     commune = Pumi::Commune.find_by_id(delivery_attempt_metadata(:commune_code))

#     beneficiary.addresses.find_or_create_by!(
#       iso_region_code: commune.province.iso3166_2,
#       administrative_division_level_2_code: commune.district_id,
#       administrative_division_level_2_name: commune.district.name_en,
#       administrative_division_level_3_code: commune.id,
#       administrative_division_level_3_name: commune.name_en,
#     )

#     commune_ids = beneficiary.metadata.fetch("commune_ids", [])
#     commune_ids << commune.id
#     beneficiary.language_code = delivery_attempt_metadata(:language_code)
#     beneficiary.metadata = {
#       "commune_ids" => commune_ids.uniq,
#       "language_code" => delivery_attempt_metadata(:language_code),
#       "latest_commune_id" => commune.id,
#       "latest_address_km" => commune.address_km,
#       "latest_address_en" => commune.address_en
#     }

#     beneficiary.save!
#   end

#   def delivery_attempt_metadata(key)
#     delivery_attempt.metadata.fetch(key.to_s)
#   end

#   def update_delivery_attempt!(data)
#     delivery_attempt.update!(
#       metadata: delivery_attempt.metadata.deep_merge(data)
#     )
#   end

#   def dtmf_tones
#     event.details["Digits"]
#   end

#   def pressed_digits
#     dtmf_tones.to_i
#   end

#   def url_helpers
#     @url_helpers ||= Rails.application.routes.url_helpers
#   end
# end
