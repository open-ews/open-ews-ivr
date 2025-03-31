module PumiLao
  District = Data.define(:id, :name_en, :name_lo, :province) do
    class << self
      def all
        DataSource.districts
      end

      def find_by!(**)
        all.find_by!(**)
      end

      def where(**)
        all.where(**)
      end
    end
  end
end
