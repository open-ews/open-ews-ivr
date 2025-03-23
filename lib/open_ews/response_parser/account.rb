require_relative "base"

module OpenEWS
  module ResponseParser
    class Account < Base
      def parse(...)
        response = super
        OpenEWS::Resource::Account.new(
          somleng_account_sid: response.attributes.fetch("somleng_account_sid"),
          somleng_auth_token: response.attributes.fetch("somleng_auth_token")
        )
      end
    end
  end
end
