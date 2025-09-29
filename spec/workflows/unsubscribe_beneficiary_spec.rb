require "spec_helper"

RSpec.describe UnsubscribeBeneficiary do
  it "deletes a beneficiary" do
    open_ews_client = build_fake_open_ews_client(list_beneficiaries: [ build_beneficiary(id: 1) ])

    UnsubscribeBeneficiary.call(open_ews_client:, phone_number: "+855715100900")

    expect(open_ews_client).to have_received(:list_beneficiaries).with(
      hash_including(
        filter: {
          phone_number: {
            eq: "+855715100900"
          }
        }
      )
    )
    expect(open_ews_client).to have_received(:delete_beneficiary).with(id: 1)
  end
end
