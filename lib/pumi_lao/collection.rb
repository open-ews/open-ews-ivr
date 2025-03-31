module PumiLao
  class Collection
    class NotFoundError < StandardError; end

    attr_reader :data

    def initialize(data)
      @data = Array(data)
    end

    def find_by!(**attributes)
      data.find(-> { raise NotFoundError }) do |member|
        attributes.all? { |key, value| member.to_h[key.to_sym] == value }
      end
    end

    def where(**attributes)
      data.find_all do |member|
        attributes.all? { |key, value| member.to_h[key.to_sym] == value }
      end
    end
  end
end
