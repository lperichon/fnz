class InstallmentsController < UserApplicationController
  include RedirectBackHelper

  before_filter :get_context

  def index
    @search = InstallmentSearch.new(params[:installment_search])
    @search.business_id = params[:business_id]
    @installments = @search.results
  end

  def show
    @installment = @context.find(params[:id])
    @contacts = @business.contacts.all_students
  end

  def edit
    @installment = @context.find(params[:id])
  	date = @installment.due_on
  	@transactions = @business.transactions.credits.where {(transaction_at.gteq(date - 1.month)) & (transaction_at.lteq(date + 1.month))}.order("transaction_at DESC")
  end

  def new
    defaults = {}
    if @membership && @membership.contact
      agent = @business.agents.enabled.where(padma_id: @membership.contact.padma_teacher).first
      if agent
        defaults.merge!({ agent_id: agent.id }) 
      end
    end

    @installment = @context.new((params[:installment]||{}).reverse_merge(defaults))

  	date = Date.today
  	@transactions = @business.transactions.credits.where {(transaction_at.gteq(date - 1.month)) & (transaction_at.lteq(date + 1.month))}.order("transaction_at DESC")
    # la linea de arriba retorna nil a veces. ver:
    # https://appsignal.com/padma/sites/5c463bba74782025e5d6f521/exceptions/incidents/111?timestamp=2019-03-20T16%3A22%3A03Z
    if @transactions.nil?
      @transactions = []
    end
  end

  # POST /accounts
  # POST /accounts.json
  def create
    if params["multiple_submit"].present?
      count = params["installments_count"].to_i
      @installment = @context.new(params[:installment])
      respond_to do |format|
        if @installment.save
          (1...count).each do |i|
            installment = @context.new(params[:installment])
            installment.due_on = installment.due_on + i.months
            installment.save
          end
          format.html do
            redirect_back_or_default_to overview_business_memberships_path(@business), notice: I18n.t('installments.create.success_multiple')
          end
        else
          format.html { render action: "new" }
        end
      end
    else
      @installment = @context.new(params[:installment])
      respond_to do |format|
        if @installment.save
          format.html do
            redirect_back_or_default_to overview_business_memberships_path(@business), notice: I18n.t('installments.create.success')
          end
          format.js {}
        else
          format.html { render action: "new" }
          format.js {}
        end
      end
    end
  end

  # PUT /accounts/1
  # PUT /accounts/1.json
  def update
    @installment = @context.readonly(false).find(params[:id]) # readonly for nested_attributes changes to work. eg. unlinking installment

    respond_to do |format|
      if @installment.update_attributes(params[:installment])
        format.html { redirect_to business_installment_path(@business, @installment), notice: _("Cuota actualizada") }
        format.js {}
        format.json { respond_with_bip(@installment) }
      else
        format.html { render action: "edit" }
        format.js {}
        format.json { respond_with_bip(@installment) }
      end
    end
  end

  # DELETE /accounts/1
  # DELETE /accounts/1.json
  def destroy
    @installment = @context.find(params[:id])
    @installment.destroy

    respond_to do |format|
      format.html { redirect_to business_membership_url(@business, @membership) }
    end
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
    end

    if params[:membership_id]
      @membership = @business.memberships.find(params[:membership_id])
      @context = @membership.installments
    else
      @context = Installment.joins(:membership).where('memberships.business_id' => @business.id)
    end
  end

end
