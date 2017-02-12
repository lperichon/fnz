class Api::V0::NotificationsController < ActionController::Base

  protect_from_forgery with: :null_session

  def mercadopago
    render :nothing => true, :status => :ok
  end

end
