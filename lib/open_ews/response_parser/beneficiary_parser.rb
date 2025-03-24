module OpenEWS
  module ResponseParser
    class BeneficiaryParser < ResourceParser
      attr_reader :beneficiary_address_parser

      def initialize(**options)
        super
        @beneficiary_address_parser = options.fetch(:beneficiary_address_parser) { BeneficiaryAddressParser.new }
      end

      def parse(...)
        resource = super

        OpenEWS::Resource::Beneficiary.new(
          id: resource.id,
          phone_number: resource.attributes.fetch("phone_number"),
          addresses: Array(resource.relationships.fetch("addresses")).map do |address|
            beneficiary_address_parser.parse(address)
          end
        )
      end
    end
  end
end
