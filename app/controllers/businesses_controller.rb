class BusinessesController < ApplicationController
  before_filter :authenticate_user!

  def index
    @businesses = current_user.businesses
  end

  def show
    @business = current_user.businesses.find(params[:id])
  end

  def edit
    @business = current_user.businesses.find(params[:id])
  end

  def new
    @business = current_user.businesses.new(params[:business])
  end

  # POST /businesses
  # POST /businesses.json
  def create
    @business = current_user.businesses.new(params[:business])

    respond_to do |format|
      if @business.save
        format.html { redirect_to business_path(@business), notice: 'Business was successfully created.' }
        format.json { render json: @business, status: :created, location: @business }
      else
        format.html { render action: "new" }
        format.json { render json: @business.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /businesses/1
  # PUT /businesses/1.json
  def update
    @business = current_user.businesses.find(params[:id])

    respond_to do |format|
      if @business.update_attributes(params[:business])
        format.html { redirect_to business_path(@business), notice: 'Business was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @business.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /businesses/1
  # DELETE /businesses/1.json
  def destroy
    @business = current_user.businesses.find(params[:id])
    @business.destroy

    respond_to do |format|
      format.html { redirect_to businesses_url }
      format.json { head :no_content }
    end
  end

end
