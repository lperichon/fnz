class CustomPrizesController < UserApplicationController

  def update
    @custom_prize = CustomPrize.find(params[:id])
    if @custom_prize.update_attributes(custom_prize_params || {})
      head :no_content
    else
      render json: @custom_prize.errors, status: :unprocessable_entity
    end
  end

  private

  def custom_prize_params
    params.require(:custom_prize).permit(
      :admpart_section,
      :agent_id,
      :amount
    ) if params[:custom_prize].present?
  end
end
