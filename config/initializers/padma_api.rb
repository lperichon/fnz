HYDRA = Typhoeus::Hydra.new

if Rails.env == 'development'
	CONFIG = YAML.load_file("#{Rails.root}/config/padma_api.yml")
else
	CONFIG = {}
end

module Crm
	URL = ENV['crm_url'] || CONFIG['crm_url']
end

module Accounts
  API_KEY = ENV['accounts_key'] || CONFIG['accounts_key']
  if ENV['C9_USER']
    HOST = "padma-accounts-#{ENV['C9_USER']}.c9users.io"
  end
end

module Contacts
  API_KEY = ENV['contacts_key'] || CONFIG['contacts_key']
  if ENV['C9_USER']
    HOST = "padma-contacts-#{ENV['C9_USER']}.c9users.io"
  end
end

module Messaging
  API_KEY = ENV['messaging_key'] || CONFIG['messaging_key']
  API_SECRET = ENV['messaging_secret'] || CONFIG['messaging_secret']
  if ENV['C9_USER']
    HOST = "padma-messaging-#{ENV['C9_USER']}.c9users.io"
  end
end