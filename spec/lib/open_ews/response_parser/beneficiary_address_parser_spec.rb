require "spec_helper"

module OpenEWS
  module ResponseParser
    RSpec.describe BeneficiaryAddressParser do
      it "parses a beneficiary response" do
        parser = BeneficiaryAddressParser.new

        beneficiary_address = parser.parse(file_fixture("lib/open_ews/beneficiary_address.json").read)

        expect(beneficiary_address).to have_attributes(
          iso_region_code: "KH-1",
          administrative_division_level_2_code: "0102",
          administrative_division_level_2_name: "Mongkol Borei",
          administrative_division_level_3_code: "010201",
          administrative_division_level_3_name: "Banteay Neang",
          administrative_division_level_4_code: "01020101",
          administrative_division_level_4_name: "Ou Thum",
        )
      end
    end
  end
end
