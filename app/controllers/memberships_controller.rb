class MembershipsController < UserApplicationController
  include RedirectBackHelper

  before_filter :get_context

  before_filter :store_current_location, only: [:index, :show, :overview]

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
    @membership = @context.new(membership_params)
  end

  # POST /accounts
  # POST /accounts.json
  def create
    padma_contact_id = params[:membership].delete(:padma_contact_id)
    permitted_params = membership_params.to_h
    permitted_params[:create_monthly_installments] = params[:membership][:create_monthly_installments]=="1"
    @membership = @context.new(permitted_params)
    @membership.padma_contact_id = padma_contact_id # set contact after initialization to ensure business has been setted
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
      if @membership.update_attributes(membership_params || {})
        format.html do
          redirect_back_or_default_to(business_membership_path(@business, @membership),
                                      notice: _('Membresía actualizada'))
        end
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
    per_page = params[:per_page]
    if params[:format].try(:to_s) == 'csv'
      per_page = 9999
    end

    init_membership_filter

    if params[:overview_mode].present? && %(list table).include?(params[:overview_mode])
      current_user.update_attribute(:overview_mode, params[:overview_mode])
    end
    if current_user.overview_mode == 'table'
      per_page ||= 50
      @contacts = @membership_filter.results.includes(current_membership: :payment_type).includes(installments: [:agent,:membership]).page(params[:page]).per(per_page)
    else
      per_page ||= 50
      @contacts = @membership_filter.results.includes(current_membership: :payment_type).page(params[:page]).per(per_page)
    end

    render layout: "application_without_sidebar"
  end

  def stats
    init_membership_filter

    @stats = MembershipStats.new(business: @business,
                                 year: params[:year].to_i, month: params[:month].to_i,
                                 membership_filter: @membership_filter)
  end

  def stats_detail
    stats
    @debug_date = Date.civil(params[:year].to_i,params[:month].to_i,1)
    render layout: "application_without_sidebar"
  end

  private

  def init_membership_filter
    default_params = {
      :contact_search => {
        :status => "student"
      }
    }
    params.reverse_merge!(default_params)
    @membership_filter = ContactSearch.new(params[:contact_search].merge(business_id: @business.id))
  end

  def get_context
    business_id = params[:business_id]
    business_id = params[:membership][:business_id] unless business_id || params[:membership].blank?
    
    @business = Business.smart_find(business_id)
    @context = @business.memberships if @business
  end

  def membership_params
    params.require(:membership).permit(
      :contact_id,
      :business_id,
      :payment_type_id,
      :begins_on,
      :ends_on,
      :value,
      :closed_on,
      :vip,
      :external_id,
      :monthly_due_day,
      :name,
      :create_monthly_installments
    ) if params[:membership].present?
  end
end
