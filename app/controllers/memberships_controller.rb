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
      format.html { redirect_back_or_default_to business_memberships_url(@business), notice: I18n.t('memberships.destroy.success') }
    end
  end

  def overview
    default_params = {
      :contact_search => {
        :status => "student"
      }
    }
    params.reverse_merge!(default_params)
    @membership_filter = ContactSearch.new(params[:contact_search].merge(:business_id => @business.id))
    if params[:overview_mode].present? && %(list table).include?(params[:overview_mode])
      current_user.update_attribute(:overview_mode, params[:overview_mode])
    end
    if current_user.overview_mode == 'table'
      @contacts = @membership_filter.results.includes(:current_membership).includes(:current_membership => :payment_type).includes(:installments).includes(:installments => :agent).includes(:installments => :membership).page(params[:page]).per(50)
    else
      @contacts = @membership_filter.results.includes(:current_membership).includes(:current_membership => :payment_type).page(params[:page]).per(100)
    end
  end

  def stats
    default_params = {
      :contact_search => {
        :status => "student"
      }
    }
    params.reverse_merge!(default_params)
    @membership_filter = ContactSearch.new(params[:contact_search].merge(:business_id => @business.id))

    @stats = MembershipStats.new(:business => @business, :year => params[:year].to_i, :month => params[:month].to_i, :membership_filter => @membership_filter)
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
