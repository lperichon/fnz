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
end

module Contacts
  API_KEY = ENV['contacts_key'] || CONFIG['contacts_key']
  if ENV['C9_USER']
    HOST = "padma-contacts-#{ENV['C9_USER']}.c9users.io"
  end
end

module Messaging
  KEY = ENV['messaging_key'] || CONFIG['messaging_key']
  if ENV['C9_USER']
    HOST = "padma-messaging-#{ENV['C9_USER']}.c9users.io"
  end
  SNS_KEY_ID = ENV['padma_aws_key_id']
  SNS_SECRET_ACCESS_KEY = ENV['padma_aws_secret_access_key']
end
