class UserBusinessesController < UserApplicationController

  # PUT /businesses/1
  # PUT /businesses/1.json
  def update
    @user_business = current_user.user_businesses.find(params[:id])

    respond_to do |format|
      if @user_business.update_attributes(params[:user_business])
        format.html { redirect_to businesses_path(), notice: 'Business was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "businesses/index" }
        format.json { render json: @user_business.errors, status: :unprocessable_entity }
      end
    end
  end


end
