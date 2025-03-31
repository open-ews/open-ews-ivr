require "spec_helper"

module PumiLao
  RSpec.describe Province do
    it "can find provinces" do
      province = Province.find_by!(id: "14")

      expect(province).to have_attributes(
        id: "14",
        name_en: "Salavan",
        name_lo: "ສາລະວັນ",
        iso3166_2: "LA-SL"
      )
    end

    it "can filter provinces" do
      provinces = Province.where(id: "14")

      expect(provinces).to contain_exactly(
        have_attributes(
          id: "14",
          name_en: "Salavan"
        )
      )
    end
  end
end
