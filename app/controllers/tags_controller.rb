class TagsController < UserApplicationController
  include TheSortableTreeController::Rebuild

  before_filter :get_business

  rescue_from NoMethodError do |exception|
    if params[:action] == "rebuild"
      # HACK 
      # the_sortable_tree BUGFIX
      #   despues de hacer el cambio pincha en algo dentro de la gem
      #   lo rescato aca.
      Tag.find(params[:id]).update_all_month_totals
      head :no_content 
    else 
      # not know bug, re raise exception
      raise exception
    end
  end

  def index
    @tags = @business.tags.nested_set
  end

  def show
    @tag = @business.tags.find(params[:id])

    @start_at = @tag.tree_transactions.order("report_at").first.report_at
    end_at = @tag.tree_transactions.order("report_at").last.report_at
    i = @start_at
    @totals = []
    while i < end_at
      @totals << @tag.month_total(i) 
      i += 1.month
    end
  end

  def edit
    @tag = @business.tags.find(params[:id])
  end

  def new
    @tag = @business.tags.new(tag_params)
  end

  # POST /tags
  # POST /tags.json
  def create
    @tag = @business.tags.new(tag_params)

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
      if @tag.update_attributes(tag_params || {})
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

  def tag_params
    params.require(:tag).permit(
      :name,
      :business_id,
      :admpart_section,
      :system_name
    ) if params[:tag].present?
  end
end
