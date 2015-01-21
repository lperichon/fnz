class MembershipsController < UserApplicationController
  include RedirectBackHelper

  before_filter :get_context

  before_filter :store_location, only: [:index, :show, :overview, :destroy]

  def index
    @search = MembershipSearch.new(params[:membership_search])
    @search.business_id = params[:business_id]
    @memberships = @search.results
  end

  def show
    @membership = @context.find(params[:id])
    @business = @membership.business
    @contacts = @business.contacts.all_students
  	@memberships = {}
  	@contacts.each do |c|
  		membership = c.current_membership
  		@memberships.merge!({c => membership})
  	end
  end

  def edit
    @membership = @context.find(params[:id])
    @business = @membership.business
	  @contacts = @business.contacts.all_students
  	@memberships = {}
    @contacts.each do |c|
  		membership = c.current_membership
  		@memberships.merge!({c => membership})
  	end
  end

  def new
    @membership = @context.new(params[:membership])
    @contacts = @business.contacts.all_students
  	@memberships = {}
  	@contacts.each do |c|
  		membership = c.current_membership
  		@memberships.merge!({c => membership})
  	end
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
      format.html { redirect_back_or_default_to business_memberships_url(@business), notice: I18n.t('memberships.destroy.success') }
    end
  end

  def overview
    @membership_filter = Membership.new(params[:membership])
  	@contacts = @business.contacts.all_students(params[:membership]).page(params[:page]).per(50)
  end

  def stats
    @stats = MembershipStats.new(:business => @business, :year => params[:year].to_i, :month => params[:month].to_i, :membership_filter => params[:membership_filter])
  end

  private

  def get_context
    business_id = params[:business_id]
    business_id = params[:membership][:business_id] unless business_id || params[:membership].blank?
    param_is_padma_id = (false if Float(business_id) rescue true)
    
    if current_user.admin?
      @business_context = Business
    else
      @business_context = current_user.businesses
    end

    if business_id
      if param_is_padma_id
        @business = @business_context.find_by_padma_id(params[:business_id])
      else
        @business = @business_context.find(params[:business_id])
      end
      @context = @business.memberships
    end
  end
end
