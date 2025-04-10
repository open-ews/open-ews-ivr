require "spec_helper"

module OpenEWS
  module ResponseParser
    RSpec.describe BeneficiaryParser do
      it "parses a beneficiary response" do
        parser = BeneficiaryParser.new

        beneficiary = parser.parse(file_fixture("lib/open_ews/beneficiary.json").read)

        expect(beneficiary).to have_attributes(
          id: "5451359",
          phone_number: "855715100999",
          iso_country_code: "KH",
          addresses: []
        )
      end
    end
  end
end
