require_relative "resource_parser"

module OpenEWS
  module ResponseParser
    class AccountParser < ResourceParser
      def parse(...)
        resource = super

        OpenEWS::Resource::Account.new(
          id: resource.id,
          somleng_account_sid: resource.attributes.fetch("somleng_account_sid"),
          somleng_auth_token: resource.attributes.fetch("somleng_auth_token")
        )
      end
    end
  end
end
