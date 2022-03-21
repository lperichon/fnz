class ReceiptsController < ApplicationController

  layout "public"

  def show
    @receipt = Receipt.w_secret(params[:secret]).find(params[:id])
  end

end
