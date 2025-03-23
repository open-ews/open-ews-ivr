OpenEWS.configure do |config|
  config.host = AppSettings.fetch(:open_ews_host)
  config.api_key = AppSettings.fetch(:open_ews_api_key)
end
