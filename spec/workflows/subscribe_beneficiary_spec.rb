require "spec_helper"

RSpec.describe SubscribeBeneficiary do
  it "creates a beneficiary" do
    open_ews_client = build_fake_open_ews_client
    attributes = {
      iso_country_code: "KH",
      phone_number: "+855715100900",
      address: {
        iso_region_code: "KH-11",
        administrative_division_level_2_code: "1102",
        administrative_division_level_2_name: "Kaoh Nheaek",
        administrative_division_level_3_code: "110203",
        administrative_division_level_3_name: "Roya"
      }
    }

    SubscribeBeneficiary.call(open_ews_client:, **attributes)

    expect(open_ews_client).to have_received(:list_beneficiaries).with(
      hash_including(
        filter: {
          phone_number: {
            eq: "+855715100900"
          }
        },
        include: :addresses
      )
    )
    expect(open_ews_client).to have_received(:create_beneficiary).with(**attributes)
  end

  it "creates a beneficiary address" do
    address_attributes = {
      iso_region_code: "KH-11",
      administrative_division_level_2_code: "1102",
      administrative_division_level_2_name: "Kaoh Nheaek",
      administrative_division_level_3_code: "110203",
      administrative_division_level_3_name: "Roya"
    }
    open_ews_client = build_fake_open_ews_client(
      list_beneficiaries: [ build_beneficiary(id: "1", addresses: []) ]
    )
    attributes = {
      iso_country_code: "KH",
      phone_number: "+855715100900",
      address: address_attributes
    }

    SubscribeBeneficiary.call(open_ews_client:, **attributes)

    expect(open_ews_client).not_to have_received(:create_beneficiary)
    expect(open_ews_client).to have_received(:create_beneficiary_address).with(beneficiary_id: "1", **address_attributes)
  end

  it "does nothing if the address already exists for the beneficiary" do
    address_attributes = {
      iso_region_code: "KH-11",
      administrative_division_level_2_code: "1102",
      administrative_division_level_2_name: "Kaoh Nheaek",
      administrative_division_level_3_code: "110203",
      administrative_division_level_3_name: "Roya"
    }
    open_ews_client = build_fake_open_ews_client(
      list_beneficiaries: [ build_beneficiary(addresses: [ build_beneficiary_address(**address_attributes) ]) ]
    )
    attributes = {
      iso_language_code: "khm",
      iso_country_code: "KH",
      phone_number: "+855715100900",
      address: address_attributes
    }

    SubscribeBeneficiary.call(open_ews_client:, **attributes)

    expect(open_ews_client).not_to have_received(:create_beneficiary)
    expect(open_ews_client).not_to have_received(:create_beneficiary_address)
  end
end
