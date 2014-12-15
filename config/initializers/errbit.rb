Airbrake.configure do |config|
  config.api_key = ENV['errbit_api_key'] || CONFIG['errbit_api_key']
  config.host    = ENV['errbit_host'] || CONFIG['errbit_host']
  config.port    = 443
  config.secure  = config.port == 443
end