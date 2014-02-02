HYDRA = Typhoeus::Hydra.new

if Rails.env == 'development'
	CONFIG = YAML.load_file("#{Rails.root}/config/padma_api.yml")
else
	CONFIG = {}
end

module Accounts
  API_KEY = ENV['accounts_key'] || CONFIG['accounts_key']
end

module Contacts
  API_KEY = ENV['contacts_key'] || CONFIG['contacts_key']
end

module Messaging
  API_KEY = ENV['messaging_key'] || CONFIG['messaging_key']
  API_SECRET = ENV['messaging_secret'] || CONFIG['messaging_secret']
end