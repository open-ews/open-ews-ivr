module OpenEWS
  module Resource
    Beneficiary = Data.define(:id, :phone_number, :iso_country_code, :addresses)
  end
end
