class AppContext
  attr_reader :source, :version, :environment

  def initialize(**options)
    @source = options.fetch(:source) { AppSettings.fetch(:app_source) }
    @version = options.fetch(:version) { AppSettings.fetch(:app_version) }
    @environment = options.fetch(:environment) { AppSettings.env }
  end

  def as_json
    {
      source:,
      version:,
      environment:
    }
  end
end
