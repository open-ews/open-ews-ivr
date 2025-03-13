class Router
  class RouteNotFoundError < Errors::NotFoundError; end

  RouteDefinition = Data.define(:http_method, :path, :controller)
  Route = Data.define(:controller, :parameters)

  ROUTE_DEFINITIONS = [
    RouteDefinition.new(http_method: :post, path: %r{\A\/ivr_flows\/(?<id>\w+)\z}, controller: IVRFlowsController)
  ].freeze

  attr_reader :request

  def initialize(request)
    @request = request
  end

  def resolve
    route = ROUTE_DEFINITIONS.find(-> { raise RouteNotFoundError }) do
      _1.http_method == request.http_method && _1.path.match?(request.path)
    end

    Route.new(controller: route.controller, parameters: route_params_for(route, request.path))
  end

  private

  def route_params_for(route, path)
    (route.path.match(path).named_captures || {}).transform_keys(&:to_sym)
  end
end
