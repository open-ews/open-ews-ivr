module PumiLao
  Province = Data.define(:id, :name_en, :name_lo, :iso3166_2) do
    class << self
      def all
        DataSource.provinces
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
