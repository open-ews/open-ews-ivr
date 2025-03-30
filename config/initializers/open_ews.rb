OpenEWS.configure do |config|
  config.host = AppSettings.fetch(:open_ews_host)
end
