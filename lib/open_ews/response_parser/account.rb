module OpenEWS
  module ResponseParser
    class Account < Base
      def parse
        super
        OpenEWS::Resource::Account.new(
          account_sid: response_attributes.fetch("somleng_account_sid"),
          auth_token: response_attributes.fetch("somleng_auth_token")
        )
      end
    end
  end
end
