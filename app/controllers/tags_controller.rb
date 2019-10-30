class TagsController < UserApplicationController
  include TheSortableTreeController::Rebuild

  before_filter :get_business

  def index
    @tags = @business.tags.nested_set
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
        format.html { redirect_to business_tags_path(@business), notice: _("Categoría creada") }
        format.json { render json: @tag, status: :created, location: business_tag_path(@business, @tag) }
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
    @business = get_context.find(params[:business_id])
  end

  def get_context
    @context = nil
    if current_user.admin?
      @context = Business
    else
      @context = current_user.businesses
    end
    @context
  end

end
