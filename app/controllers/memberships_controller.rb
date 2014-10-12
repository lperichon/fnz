class MembershipsController < UserApplicationController
  before_filter :get_context

  def index
    @overdue_installments = Installment.joins(:membership).where("memberships.business_id = #{@business.id}").overdue.incomplete
    @due_installments = Installment.joins(:membership).where("memberships.business_id = #{@business.id}").due.incomplete
    @stats = MembershipStats.new(:business => @business, :year => Date.today.year, :month => Date.today.month)
    @contacts = @business.contacts.all_students
  	@memberships = {}
  	@contacts.each do |c|
  		membership = c.current_membership
  		@memberships.merge!({c => membership})
  	end
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
      format.html { redirect_to business_memberships_url(@business) }
    end
  end

  def overview
    @membership_filter = Membership.new(params[:membership])
  	@contacts = @business.contacts.all_students(params[:membership]).page(params[:page]).per(100)
  	@installments = {}
  	@memberships = {}
  	@contacts.each do |c|
  		membership = c.current_membership
  		@memberships.merge!({c => membership})

  		installments = (membership && !membership.closed?) ? membership.installments : []
  		@installments.merge!({c => installments})
  	end
  end

  def maturity_report
    if params[:membership_search].nil?
      attr = {ends_after: Date.today.beginning_of_month, ends_before: Date.today.end_of_month}
    else
      attr = params[:membership_search]
    end
    @search = MembershipSearch.new(attr)
    @search.business_id = params[:business_id]
  end

  def stats
    @stats = MembershipStats.new(:business => @business, :year => params[:year].to_i, :month => params[:month].to_i)
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
