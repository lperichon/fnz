class UserApplicationController < ApplicationController
  include SsoSessionsHelper

  before_filter :secret_key_login
  before_filter :get_sso_session
  before_filter :authenticate_user!
  before_filter :set_current_user
  before_filter :set_time_zone
  before_filter :set_locale

  def set_current_user
    User.current_user = current_user if current_user
  end

  def set_time_zone
    Time.zone = current_user.time_zone if current_user
  end

  def set_locale
  	user_locale = current_user.try :locale
  	I18n.locale = user_locale if user_locale

    # If locale is sent by params override all
    I18n.locale = params[:locale] if params[:locale]
  end

  def secret_key_login
    unless signed_in?
      unless params[:secret_key_login].blank?
        key = params[:secret_key_login]
        apikey = Rails.cache.fetch("apikey#{key}", expires_in: 10.minutes) do
          ApiKey.find key
        end
        if apikey.access == 'login_key'
          user = nil
          if apikey.username
            user = User.find_or_create_by_drc_uid(apikey.username)
          end
          sign_in(user)
        end
      end
    end
  end
end
