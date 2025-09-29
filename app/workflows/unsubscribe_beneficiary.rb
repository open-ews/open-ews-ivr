class UnsubscribeBeneficiary
  attr_reader :open_ews_client, :phone_number

  def initialize(open_ews_client:, phone_number:)
    @open_ews_client = open_ews_client
    @phone_number = phone_number
  end

  def self.call(...)
    new(...).call
  end

  def call
    delete_beneficiary if beneficiary_exists?
  end

  private

  def beneficiary_exists?
    !!existing_beneficiary
  end

  def existing_beneficiary
    existing_beneficiaries.resources.first
  end

  def existing_beneficiaries
    @existing_beneficiaries ||= open_ews_client.list_beneficiaries(
      filter: {
        phone_number: {
          eq: phone_number
        }
      }
    )
  end

  def delete_beneficiary
    open_ews_client.delete_beneficiary(id: existing_beneficiary.id)
  end
end
