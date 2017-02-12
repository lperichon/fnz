class Api::V0::NotificationsController < ActionController::Base

  protect_from_forgery with: :null_session

  def mercadopago
    render json: "OK", status: 201
  end

end
