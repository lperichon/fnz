class EnrollmentsController < UserApplicationController
  before_filter :get_context

  def show
  end

  def edit
  end

  def new
    @enrollment = @membership.build_enrollment(params[:enrollment])
  end

  # POST /enrollments
  # POST /enrollments.json
  def create
    @enrollment = @membership.build_enrollment(params[:enrollment])

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
      if @enrollment.update_attributes(params[:enrollment])
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
    @business = current_user.businesses.find(params[:business_id])
    @membership = @business.memberships.find(params[:membership_id])
    @enrollment = @membership.enrollment
  end
end
