class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def cas
    @user = User.find_for_cas_oauth(request.env["omniauth.auth"], current_user)

    if @user.persisted?
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "DeRose Connect"
      sign_in_and_redirect @user, :event => :authentication
    else
      session["devise.cas_data"] = request.env["omniauth.auth"]
      redirect_to new_user_session_path
    end
  end

  def failure
    logger.debug "DEBUG FAILURE #{request.env}"
    logger.debug "DEBUG FAILURE #{params}"
  end
end

