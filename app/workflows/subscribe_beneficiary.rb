class SubscribeBeneficiary
  attr_reader :open_ews_client, :beneficiary_attributes

  def initialize(open_ews_client:, **beneficiary_attributes)
    @open_ews_client = open_ews_client
    @beneficiary_attributes = beneficiary_attributes
  end

  def self.call(...)
    new(...).call
  end

  def call
    return if beneficiary_exists? && address_exists?

    beneficiary_exists? ? create_address : create_beneficiary
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
          eq: beneficiary_attributes.fetch(:phone_number)
        }
      },
      include: :addresses
    )
  end

  def address_attributes
    beneficiary_attributes.fetch(:address, {})
  end

  def address_exists?
    return false if existing_beneficiary.nil?
    return false if address_attributes.empty?

     address = existing_beneficiary.addresses.find do
      _1.administrative_division_level_4_code == address_attributes[:administrative_division_level_4_code] &&
      _1.administrative_division_level_3_code == address_attributes[:administrative_division_level_3_code] &&
      _1.administrative_division_level_2_code == address_attributes[:administrative_division_level_2_code] &&
      _1.iso_region_code == address_attributes[:iso_region_code]
    end

    !!address
  end

  def create_address
    open_ews_client.create_beneficiary_address(beneficiary_id: existing_beneficiary.id, **address_attributes)
  end

  def create_beneficiary
    open_ews_client.create_beneficiary(**beneficiary_attributes)
  end
end
