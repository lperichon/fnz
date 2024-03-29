class SsoSessionsController < ApplicationController
  include SsoSessionsHelper

  def show
    get_sso_session
  end

  # GET sso_sessions/new
  # quivalent to POST sso_sessions
  #
  # reads params:
  #   sso_token , will validate this with PADMA's SSO to start session
  #   destination , after signin will redirect to this url
  def new
    create
  end

  def create
    st = SsoToken.find params[:sso_token]
    if st && !st.account_name.blank? && !st.username.blank?

      user = User.create_or_update_from_sso(st.username)
      sign_in(user)

      if params[:destination].blank?
        redirect_to root_url
      else
        redirect_to destination_with_full_query_string
      end
    else
      render text: "got invalid token #{params[:sso_token]}"
    end
  end

  def destroy
    sign_out
    redirect_to padma_sso_logout_url
  end
end
