class AppContext
  attr_reader :source, :version

  def initialize(**options)
    @source = options.fetch(:source) { AppSettings.fetch(:app_source) }
    @version = options.fetch(:version) { AppSettings.fetch(:app_version) }
  end

  def as_json
    {
      source:,
      version:
    }
  end
end
