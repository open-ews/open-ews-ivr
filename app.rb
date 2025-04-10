require "logger"
require_relative "config/application"

module App
  class Handler
    attr_reader :payload, :request_parser, :context, :logger

    def self.process(event:, context:)
      new(payload: event, context:).process
    end

    def initialize(payload:, **options)
      @payload = payload
      @context = options.fetch(:context)
      @request_parser = options.fetch(:request_parser) { RequestParser.new }
      @logger = options.fetch(:logger) { Logger.new($stdout) }
    end

    def process
      logger.info("Processing Request: #{payload}")
      request = request_parser.parse(payload)
      route = Router.new(request).resolve
      response = route.controller.new.public_send(route.action, request:, route:)
      logger.info(serialize(response))
      serialize(response)
    rescue Errors::NotFoundError
      serialize(ALBResponse::NotFoundResponse)
    rescue Exception => e
      raise(e) unless [ "production", "staging" ].include?(AppSettings.env)
      logger.error(e)
      Sentry.capture_exception(e)
      serialize(ALBResponse::InternalServerErrorResponse)
    end

    def serialize(response)
      ALBResponseSerializer.new(response).as_json
    end
  end
end
