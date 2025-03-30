module OpenEWS
  module ResponseParser
    class BeneficiaryAddressParser < ResourceParser
      def parse(...)
        resource = super

        OpenEWS::Resource::BeneficiaryAddress.new(
          iso_region_code: resource.attributes.fetch("iso_region_code"),
          administrative_division_level_2_code: resource.attributes.fetch("administrative_division_level_2_code"),
          administrative_division_level_2_name: resource.attributes.fetch("administrative_division_level_2_name"),
          administrative_division_level_3_code: resource.attributes.fetch("administrative_division_level_3_code"),
          administrative_division_level_3_name: resource.attributes.fetch("administrative_division_level_3_name"),
          administrative_division_level_4_code: resource.attributes.fetch("administrative_division_level_4_code"),
          administrative_division_level_4_name: resource.attributes.fetch("administrative_division_level_4_name")
        )
      end
    end
  end
end
