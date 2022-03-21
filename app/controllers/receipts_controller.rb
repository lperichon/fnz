class ReceiptsController < ApplicationController

  layout "receipts"

  def show
    @receipt = Receipt.w_secret(params[:s]).find(params[:id])
  end

end
