class AccountsController < UserApplicationController
  before_filter :get_business

  def index
    @accounts = @business.accounts.with_deleted
  end

  def show
    @account = @business.accounts.with_deleted.find(params[:id])
  end

  def edit
    @account = @business.accounts.with_deleted.find(params[:id])
  end

  def new
    @account = @business.accounts.new(params[:account])
  end

  # POST /accounts
  # POST /accounts.json
  def create
    @account = @business.accounts.new(params[:account])

    respond_to do |format|
      if @account.save
        format.html { redirect_to business_account_path(@business, @account), notice: 'Account was successfully created.' }
        format.json { render json: @account, status: :created, location: @account }
      else
        format.html { render action: "new" }
        format.json { render json: @account.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /accounts/1
  # PUT /accounts/1.json
  def update
    @account = @business.accounts.with_deleted.find(params[:id])

    respond_to do |format|
      if @account.update_attributes(params[:account])
        format.html { redirect_to business_account_path(@business, @account), notice: 'Account was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @account.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /accounts/1
  # DELETE /accounts/1.json
  def destroy
    @account = @business.accounts.with_deleted.find(params[:id])
    if @account.deleted?
      @account.update_attribute(:deleted_at, nil)
    else
      @account.destroy
    end

    respond_to do |format|
      format.html { redirect_to business_accounts_url(@business) }
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
