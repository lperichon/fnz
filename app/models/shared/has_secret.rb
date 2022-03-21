require 'securerandom'

# requires url_secret and url_secret=
module Shared::HasSecret
  extend ActiveSupport::Concern

  included do

    scope :w_secret, ->(secret) { where(url_secret: secret) }

    before_save :set_public_access_secret

    def valid_secret?(candidate)
      url_secret.present? && candidate == url_secret
    end

    def set_public_access_secret
      if url_secret.blank?
        self.url_secret = SecureRandom.uuid
      end
    end
  end
end
