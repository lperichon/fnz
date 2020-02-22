class CustomPrizesController < UserApplicationController

  def update
    @custom_prize = CustomPrize.find(params[:id])
    if @custom_prize.update_attributes(params[:custom_prize])
      head :no_content
    else
      render json: @custom_prize.errors, status: :unprocessable_entity
    end
  end

end
