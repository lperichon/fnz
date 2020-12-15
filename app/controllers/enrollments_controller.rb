class EnrollmentsController < UserApplicationController
  before_filter :get_context

  def show
  end

  def edit
  	date = @enrollment.enrolled_on || Date.today
  	@transactions = @business.trans.credits.where {(transaction_at.gteq date - 1.month) & (transaction_at.lteq  date + 1.month)}
  end

  def new
    @enrollment = @membership.build_enrollment(enrollment_params)
  	date = @enrollment.enrolled_on || Date.today
  	@transactions = @business.trans.credits.where {(transaction_at.gteq date - 1.month) & (transaction_at.lteq  date + 1.month)}
  end

  # POST /enrollments
  # POST /enrollments.json
  def create
    @enrollment = @membership.build_enrollment(enrollment_params)

    respond_to do |format|
      if @enrollment.save
        format.html { redirect_to business_membership_enrollment_path(@business, @membership, @enrollment), notice: 'Enrollment was successfully created.' }
      else
        format.html { render action: "new" }
      end
    end
  end

  # PUT /enrollments/1
  # PUT /enrollments/1.json
  def update
    respond_to do |format|
      if @enrollment.update_attributes(enrollment_params || {})
        format.html { redirect_to business_membership_enrollment_path(@business, @membership, @enrollment), notice: 'Enrollment was successfully updated.' }
      else
        format.html { render action: "edit" }
      end
    end
  end

  # DELETE /enrollments/1
  # DELETE /enrollments/1.json
  def destroy
    @enrollment.destroy

    respond_to do |format|
      format.html { redirect_to business_membership_url(@business, @membership) }
    end
  end

  private

  def get_context
    if current_user.admin?
      @context = Business
    else
      @context = current_user.businesses
    end  

    @business = @context.find(params[:business_id])
    @membership = @business.memberships.find(params[:membership_id])
    @enrollment = @membership.enrollment
  end

  def enrollment_params
    params.require(:enrollment).permit(
      :membership_id,
      :agent_id,
      :value,
      :enrolled_on,
      :transactions_attributes,
      :enrollment_transactions_attributes
    ) if params[:enrollment].present?
  end
end
