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
    ) do
      class << self
        def empty
          new(**members.index_with { nil })
        end
      end

      def empty?
        to_h.values.all?(&:nil?)
      end
    end
  end
end
