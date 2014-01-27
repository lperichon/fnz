class InstallmentsController < UserApplicationController
  before_filter :get_context

  def index
    @installments = @context.all
  end

  def show
    @installment = @context.find(params[:id])
    @contacts = @business.contacts.all_students
  	@installments = {}
  	@memberships = {}
  	@contacts.each do |c|
  		membership = c.membership
  		@memberships.merge!({c => membership})
  	end
  end

  def edit
    @installment = @context.find(params[:id])
    @contacts = @business.contacts.all_students
  	@installments = {}
  	@memberships = {}
  	@contacts.each do |c|
  		membership = c.membership
  		@memberships.merge!({c => membership})
  	end
  	date = @installment.due_on
  	@transactions = @business.transactions.credits.where {(transaction_at.gteq(date - 1.month)) & (transaction_at.lteq(date + 1.month))}.order("transaction_at DESC")
  end

  def new
    @installment = @context.new(params[:installment])
    @contacts = @business.contacts.all_students
  	@memberships = {}
  	@contacts.each do |c|
  		membership = c.membership
  		@memberships.merge!({c => membership})
  	end
  	date = @installment.due_on || Date.today
  	@transactions = @business.transactions.credits.where {(transaction_at.gteq(date - 1.month)) & (transaction_at.lteq(date + 1.month))}.order("transaction_at DESC")
  end

  # POST /accounts
  # POST /accounts.json
  def create
    @installment = @context.new(params[:installment])

    respond_to do |format|
      if @installment.save
        format.html { redirect_to business_membership_installment_path(@business, @membership, @installment), notice: 'Installment was successfully created.' }
      else
        format.html { render action: "new" }
      end
    end
  end

  # PUT /accounts/1
  # PUT /accounts/1.json
  def update
    @installment = @context.find(params[:id])

    respond_to do |format|
      if @installment.update_attributes(params[:installment])
        format.html { redirect_to business_membership_installment_path(@business, @membership, @installment), notice: 'Installment was successfully updated.' }
      else
        format.html { render action: "edit" }
      end
    end
  end

  # DELETE /accounts/1
  # DELETE /accounts/1.json
  def destroy
    @installment = @context.find(params[:id])
    @installment.destroy

    respond_to do |format|
      format.html { redirect_to business_membership_installments_url(@business, @membership) }
    end
  end

  private

  def get_context
    @business = current_user.businesses.find(params[:business_id])
    @membership = @business.memberships.find(params[:membership_id])
    @context = @membership.installments
  end

end
