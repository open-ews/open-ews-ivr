module OpenEWS
  module Resource
    BeneficiaryAddress = Data.define(
      :iso_region_code,
      :administrative_division_level_2_code,
      :administrative_division_level_2_name,
      :administrative_division_level_3_code,
      :administrative_division_level_3_name,
      :administrative_division_level_4_code,
      :administrative_division_level_4_name
    )
  end
end
