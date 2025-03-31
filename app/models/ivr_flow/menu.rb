module IVRFlow
  class Menu
    attr_reader :request

    def initialize(request, **options)
      @request = request
      @start_over = options.fetch(:start_over) { -> { request.twilio.digits == "*" } }
    end

    def start_over?
      !!@start_over.call
    end
  end
end
