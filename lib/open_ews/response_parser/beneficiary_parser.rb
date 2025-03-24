module OpenEWS
  module ResponseParser
    class BeneficiaryParser < ResourceParser
      def parse(...)
        resource = super

        OpenEWS::Resource::Beneficiary.new(
          id: resource.id,
          phone_number: resource.attributes.fetch("phone_number"),
          addresses: Array(resource.relationships.fetch("addresses")).map do |address|
            OpenEWS::Resource::BeneficiaryAddress.new(
              iso_region_code: address.attributes.fetch("iso_region_code"),
              administrative_division_level_2_code: address.attributes.fetch("administrative_division_level_2_code"),
              administrative_division_level_2_name: address.attributes.fetch("administrative_division_level_2_name"),
              administrative_division_level_3_code: address.attributes.fetch("administrative_division_level_3_code"),
              administrative_division_level_3_name: address.attributes.fetch("administrative_division_level_3_name"),
              administrative_division_level_4_code: address.attributes.fetch("administrative_division_level_4_code"),
              administrative_division_level_4_name: address.attributes.fetch("administrative_division_level_4_name")
            )
          end
        )
      end
    end
  end
end
