class Router
  class RouteNotFoundError < Errors::NotFoundError; end

  RouteDefinition = Data.define(:http_method, :path, :controller, :action)
  Route = Data.define(:controller, :action, :parameters)

  ROUTE_DEFINITIONS = [
    RouteDefinition.new(http_method: :post, path: %r{\A\/ivr_flows\/(?<id>\w+)\z}, controller: IVRFlowsController, action: :create),
    RouteDefinition.new(http_method: :post, path: "/ivr_flows/ews_1294_cambodia/feedback", controller: EWS1294Cambodia::FeedbackController, action: :create)
  ].freeze

  attr_reader :request

  def initialize(request)
    @request = request
  end

  def self.find_route_definition(path:, http_method:)
    ROUTE_DEFINITIONS.find(-> { raise RouteNotFoundError }) do
      _1.path.match?(path) && _1.http_method == http_method
    end
  end

  def self.url_for(scheme: "https", host:, path:)
    URI::Generic.build(scheme:, host:, path:).to_s
  end

  def resolve
    route_definition = self.class.find_route_definition(http_method: request.http_method, path: request.path)
    Route.new(controller: route_definition.controller, action: route_definition.action, parameters: route_params_for(route_definition, request.path))
  end

  private

  def route_params_for(route_definition, path)
    (route_definition.path.match(path).named_captures || {}).transform_keys(&:to_sym)
  end
end
