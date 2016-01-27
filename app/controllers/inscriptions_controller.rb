class InscriptionsController < UserApplicationController
  include RedirectBackHelper

  before_filter :get_context

  def index
    @search = InscriptionSearch.new(params[:inscription_search])
    @search.business_id = params[:business_id]
    @inscriptions = @search.results
  end

  def show
    @inscription = @context.find(params[:id])
  end

  def edit
    @inscription = @context.find(params[:id])
  	@transactions = @business.transactions.credits.order("transaction_at DESC")
  end

  def new
    @inscription = @context.new(params[:inscription])
  	@transactions = @business.transactions.credits.order("transaction_at DESC")
  end

  # POST /accounts
  # POST /accounts.json
  def create
    @inscription = @context.new(params[:inscription])
    respond_to do |format|
      if @inscription.save
        format.html do
          redirect_back_or_default_to business_inscriptions_path(@business), notice: I18n.t('inscriptions.create.success')
        end
      else
        format.html { render action: "new" }
      end
    end
  end

  # PUT /accounts/1
  # PUT /accounts/1.json
  def update
    @inscription = @context.find(params[:id])

    respond_to do |format|
      if @inscription.update_attributes(params[:inscription])
        format.html { redirect_to business_inscription_path(@business, @inscription), notice: 'Inscription was successfully updated.' }
      else
        format.html { render action: "edit" }
      end
    end
  end

  # DELETE /accounts/1
  # DELETE /accounts/1.json
  def destroy
    @inscription = @context.find(params[:id])
    @inscription.destroy

    respond_to do |format|
      format.html { redirect_to business_inscriptions_url(@business) }
    end
  end

  private

  def get_context
    business_id = params[:business_id]
    business_id = params[:inscription][:business_id] unless business_id || params[:inscription].blank?
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

    @context = @business.inscriptions

  end

end
