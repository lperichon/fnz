class TagsController < ApplicationController
  before_filter :authenticate_user!

  before_filter :get_business

  def index
    @tags = @business.tags
  end

  def show
    @tag = @business.tags.find(params[:id])
  end

  def edit
    @tag = @business.tags.find(params[:id])
  end

  def new
    @tag = @business.tags.new(params[:tag])
  end

  # POST /tags
  # POST /tags.json
  def create
    @tag = @business.tags.new(params[:tag])

    respond_to do |format|
      if @tag.save
        format.html { redirect_to business_tag_path(@business, @tag), notice: 'Tag was successfully created.' }
        format.json { render json: @tag, status: :created, location: @tag }
      else
        format.html { render action: "new" }
        format.json { render json: @tag.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /tags/1
  # PUT /tags/1.json
  def update
    @tag = @business.tags.find(params[:id])

    respond_to do |format|
      if @tag.update_attributes(params[:tag])
        format.html { redirect_to business_tag_path(@business, @tag), notice: 'Tag was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @tag.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tags/1
  # DELETE /tags/1.json
  def destroy
    @tag = @business.tags.find(params[:id])
    @tag.destroy

    respond_to do |format|
      format.html { redirect_to business_tags_url(@business) }
      format.json { head :no_content }
    end
  end

  private

  def get_business
    @business = current_user.businesses.find(params[:business_id])
  end

end
