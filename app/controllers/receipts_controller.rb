class ReceiptsController < ApplicationController

  layout "public"

  def show
    @receipt = Receipt.w_secret(params[:s]).find(params[:id])
  end

end
