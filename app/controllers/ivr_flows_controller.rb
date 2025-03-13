class IVRFlowsController
  def handle(request:, route:)
    ivr_flow = IVRFlow::Collection.find(route.parameters.fetch(:id))
    handler = ivr_flow.handler.new(request:)
    handler.call
  end
end
