require "spec_helper"

module OpenEWS
  RSpec.describe Client do
    describe "#create_beneficiary" do
      it "creates a new beneficiary" do
        client = Client.new(api_key: "open-ews-api-key")

        stub_request(:post, "https://api.open-ews.org/v1/beneficiaries").to_return(
          body: JSON.dump(
            {
              data: {
                id: "1",
                type: "beneficiary",
                attributes: {
                  phone_number: "855715100987",
                  iso_country_code: "KH"
                },
                relationships: {
                  addresses: {
                    data: [
                      {
                        id: "1",
                        type: "address"
                      }
                    ]
                  }
                }
              },
              included: [
                {
                  id: "1",
                  type: "address",
                  attributes: {
                    iso_region_code: "KH-1",
                    administrative_division_level_2_code: "0102",
                    administrative_division_level_2_name: "Mongkol Borei",
                    administrative_division_level_3_code: "010201",
                    administrative_division_level_3_name: "Banteay Neang",
                    administrative_division_level_4_code: "01020101",
                    administrative_division_level_4_name: "Ou Thum"
                  }
                }
              ]
            }
          )
        )

        response = client.create_beneficiary(
          iso_country_code: "KH",
          phone_number: "855715100987",
          address: {
            iso_region_code: "KH-1",
            administrative_division_level_2_code: "0102",
            administrative_division_level_2_name: "Mongkol Borei",
            administrative_division_level_3_code: "010201",
            administrative_division_level_3_name: "Banteay Neang",
            administrative_division_level_4_code: "01020101",
            administrative_division_level_4_name: "Ou Thum"
          }
        )

        expect(response).to have_attributes(
          id: "1",
          iso_country_code: "KH",
          phone_number: "855715100987",
          addresses: contain_exactly(
            have_attributes(
              iso_region_code: "KH-1",
              administrative_division_level_2_code: "0102",
              administrative_division_level_2_name: "Mongkol Borei",
              administrative_division_level_3_code: "010201",
              administrative_division_level_3_name: "Banteay Neang",
              administrative_division_level_4_code: "01020101",
              administrative_division_level_4_name: "Ou Thum"
            )
          )
        )

        expect(WebMock).to have_requested(
          :post,
          "https://api.open-ews.org/v1/beneficiaries"
        ).with(
          headers: {
            "Authorization" => "Bearer open-ews-api-key"
          },
          body: JSON.dump(
            {
              data: {
                type: "beneficiary",
                attributes: {
                  iso_country_code: "KH",
                  phone_number: "855715100987",
                  address: {
                    iso_region_code: "KH-1",
                    administrative_division_level_2_code: "0102",
                    administrative_division_level_2_name: "Mongkol Borei",
                    administrative_division_level_3_code: "010201",
                    administrative_division_level_3_name: "Banteay Neang",
                    administrative_division_level_4_code: "01020101",
                    administrative_division_level_4_name: "Ou Thum"
                  }
                }
              }
            }
          )
        )
      end
    end

    describe "#list_beneficiaries" do
      it "filters beneficiaries" do
        client = Client.new

        stub_request(:get, %r{https://api.open-ews.org/v1/beneficiaries}).to_return(
          body: JSON.dump(
            {
              data: [
                {
                  id: "1",
                  type: "beneficiary",
                  attributes: {
                    phone_number: "85592276589",
                    iso_country_code: "KH"
                  },
                  relationships: {
                    addresses: {
                      data: [
                        {
                          id: "1",
                          type: "address"
                        }
                      ]
                    }
                  }
                }
              ],
              included: [
                {
                  id: "1",
                  type: "address",
                  attributes: {
                    iso_region_code: "KH-17",
                    administrative_division_level_2_code: "1702",
                    administrative_division_level_2_name: "Angkor Thum",
                    administrative_division_level_3_code: "170201",
                    administrative_division_level_3_name: "Chob Ta Trav",
                    administrative_division_level_4_code: nil,
                    administrative_division_level_4_name: nil
                  }
                }
              ],
              links: {
                prev: "https://api.open-ews.org/v1/beneficiaries?include=addresses\u0026page%5Bbefore%5D=1",
                next: "https://api.open-ews.org//v1/beneficiaries?include=addresses\u0026page%5Bafter%5D=1"
              }
            }
          )
        )

        response = client.list_beneficiaries(
          filter: {
            iso_country_code: { eq: "KH" },
            phone_number: { eq: "85592276589" }
          },
          include: :addresses
        )

        expect(response.resources).to contain_exactly(
          have_attributes(
            id: "1",
            phone_number: "85592276589",
            iso_country_code: "KH",
            addresses: contain_exactly(
              have_attributes(
                iso_region_code: "KH-17",
                administrative_division_level_2_code: "1702",
                administrative_division_level_2_name: "Angkor Thum",
                administrative_division_level_3_code: "170201",
                administrative_division_level_3_name: "Chob Ta Trav",
                administrative_division_level_4_code: nil,
                administrative_division_level_4_name: nil
              )
            )
          )
        )
        expect(WebMock).to have_requested(
          :get,
          "https://api.open-ews.org/v1/beneficiaries"
        ).with(
          query: hash_including(
            filter: {
              iso_country_code: { eq: "KH" },
              phone_number: { eq: "85592276589" }
            },
            include: "addresses"
          )
        )
      end
    end

    describe "#create_beneficiary_address" do
      it "creates a beneficiary address" do
        client = Client.new

        stub_request(:post, "https://api.open-ews.org/v1/beneficiaries/1/addresses").to_return(
          body: JSON.dump(
            {
              data: {
                id: "1",
                type: "address",
                attributes: {
                  iso_region_code: "KH-1",
                  administrative_division_level_2_code: "0102",
                  administrative_division_level_2_name: "Mongkol Borei",
                  administrative_division_level_3_code: "010201",
                  administrative_division_level_3_name: "Banteay Neang",
                  administrative_division_level_4_code: "01020101",
                  administrative_division_level_4_name: "Ou Thum"
                }
              }
            }
          )
        )

        response = client.create_beneficiary_address(
          beneficiary_id: "1",
          iso_region_code: "KH-1",
          administrative_division_level_2_code: "0102",
          administrative_division_level_2_name: "Mongkol Borei",
          administrative_division_level_3_code: "010201",
          administrative_division_level_3_name: "Banteay Neang",
          administrative_division_level_4_code: "01020101",
          administrative_division_level_4_name: "Ou Thum"
        )

        expect(response).to have_attributes(
          iso_region_code: "KH-1",
          administrative_division_level_2_code: "0102",
          administrative_division_level_2_name: "Mongkol Borei",
          administrative_division_level_3_code: "010201",
          administrative_division_level_3_name: "Banteay Neang",
          administrative_division_level_4_code: "01020101",
          administrative_division_level_4_name: "Ou Thum"
        )

        expect(WebMock).to have_requested(
          :post,
          "https://api.open-ews.org/v1/beneficiaries/1/addresses"
        ).with(
          body: JSON.dump(
            {
              data: {
                type: "beneficiary_address",
                attributes: {
                  iso_region_code: "KH-1",
                  administrative_division_level_2_code: "0102",
                  administrative_division_level_2_name: "Mongkol Borei",
                  administrative_division_level_3_code: "010201",
                  administrative_division_level_3_name: "Banteay Neang",
                  administrative_division_level_4_code: "01020101",
                  administrative_division_level_4_name: "Ou Thum"
                }
              }
            }
          )
        )
      end
    end

    describe "#fetch_account_settings" do
      it "fetches account settings" do
        client = Client.new

        stub_request(:get, "https://api.open-ews.org/v1/account").to_return(
          body: JSON.dump(
            {
              data: {
                id: "1",
                type: "account",
                attributes: {
                  somleng_account_sid: "ee86bd53-626d-4139-8143-608a267c8b71",
                  somleng_auth_token: "6GmFR2ny48GrmlIldBTg9fG4OC6lI5W5Pn70YkADD1b"
                }
              }
            }
          )
        )

        response = client.fetch_account_settings

        expect(response).to have_attributes(
          id: "1",
          somleng_account_sid: "ee86bd53-626d-4139-8143-608a267c8b71",
          somleng_auth_token: "6GmFR2ny48GrmlIldBTg9fG4OC6lI5W5Pn70YkADD1b"
        )
      end
    end
  end
end
