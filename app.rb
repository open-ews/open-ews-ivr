require "logger"

require_relative "config/application"

module App
  class Handler
    attr_reader :event, :context, :logger

    def self.process(event:, context:)
      logger = Logger.new($stdout)
      logger.info("## Processing Event")
      logger.info(event)

      new(event:, context:, logger:).process
    rescue Exception => e
      Sentry.capture_exception(e)
      raise(e)
    end

    def initialize(event:, **options)
      @event = ALBEventParser.new.parse(event)
      @context = options.fetch(:context)
      @logger = options.fetch(:logger)
    end

    def process
      logger.info(event)
    end
  end
end
