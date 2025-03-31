require "spec_helper"

module PumiLao
  RSpec.describe District do
    it "can find districts" do
      district = District.find_by!(id: "1601")

      expect(district).to have_attributes(
        id: "1601",
        name_en: "Pakse",
        name_lo: "ປາກເຊ",
        province: have_attributes(
          id: "16",
          iso3166_2: "LA-CH"
        )
      )
    end

    it "returns all districts for a province" do
      districts = District.where(province: Province.find_by!(id: "16"))
      expect(districts.size).to eq(10)
    end
  end
end
