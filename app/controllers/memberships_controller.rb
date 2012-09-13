class MembershipsController < UserApplicationController
  before_filter :get_context

  def index
    @memberships = @context.all
  end

  def show
    @membership = @context.find(params[:id])
    @business = @membership.business
  end

  def edit
    @membership = @context.find(params[:id])
    @business = @membership.business
  end

  def new
    @membership = @context.new(params[:membership])
  end

  # POST /accounts
  # POST /accounts.json
  def create
    @membership = @context.new(params[:membership])
    @business = @membership.business

    respond_to do |format|
      if @membership.save
        format.html { redirect_to business_membership_path(@business, @membership), notice: 'Membership was successfully created.' }
      else
        format.html { render action: "new" }
      end
    end
  end

  # PUT /accounts/1
  # PUT /accounts/1.json
  def update
    @membership = @context.find(params[:id])
    @business = @membership.business

    respond_to do |format|
      if @membership.update_attributes(params[:membership])
        format.html { redirect_to business_membership_path(@business, @membership), notice: 'Membership was successfully updated.' }
      else
        format.html { render action: "edit" }
      end
    end
  end

  # DELETE /accounts/1
  # DELETE /accounts/1.json
  def destroy
    @membership = @context.find(params[:id])
    @business = @membership.business unless @business
    @membership.destroy

    respond_to do |format|
      format.html { redirect_to business_memberships_url(@business) }
    end
  end

  private

  def get_context
    business_id = params[:business_id]
    business_id = params[:membership][:business_id] unless business_id || params[:membership].blank?
    @context = Membership
    if business_id
      @business = current_user.businesses.find(business_id)
      @context = @business.memberships
    end
  end

end
