require 'spec_helper'

describe EnrollmentsController do

  # This should return the minimal set of attributes required to create a valid
  # Business. As you add validations to Business, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    {
        :membership_id => @membership.id,
        :value => 3.2
    }
  end

  before(:each) do
    @business = FactoryGirl.create(:school)
    @membership = FactoryGirl.create(:membership, :business => @business)
    @user = @business.owner
    sign_in @user
  end

  describe "GET show" do
    it "should be successful" do
      enrollment = @membership.create_enrollment! valid_attributes
      get :show, :business_id => @business.to_param, :membership_id => @membership.to_param
      response.should be_success
    end

    it "assigns the requested enrollment as @enrollment" do
      enrollment = @membership.create_enrollment! valid_attributes
      get :show, :business_id => @business.to_param, :membership_id => @membership.to_param
      assigns(:enrollment).should == enrollment
    end
  end

  describe "GET new" do
    it "assigns a new enrollment as @enrollment" do
      get :new, :business_id => @business.to_param, :membership_id => @membership.to_param
      assigns(:enrollment).should be_a_new(Enrollment)
    end
  end

  describe "GET edit" do
    it "assigns the requested enrollment as @enrollment" do
      enrollment = @membership.create_enrollment! valid_attributes
      get :edit, :business_id => @business.to_param, :membership_id => @membership.to_param
      assigns(:enrollment).should eq(enrollment)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Enrollment" do
        expect {
          post :create, {:business_id => @business.to_param, :membership_id => @membership.to_param, :enrollment => valid_attributes}
        }.to change(Enrollment, :count).by(1)
      end

      it "assigns a newly created enrollment as @enrollment" do
        post :create, {:business_id => @business.to_param, :membership_id => @membership.to_param, :enrollment => valid_attributes}
        assigns(:enrollment).should be_a(Enrollment)
        assigns(:enrollment).should be_persisted
      end

      it "redirects to the created enrollment" do
        post :create, {:business_id => @business.to_param, :membership_id => @membership.to_param, :enrollment => valid_attributes}
        response.should redirect_to(business_membership_enrollment_url(@business, @membership, Enrollment.last))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved enrollment as @enrollment" do
        # Trigger the behavior that occurs when invalid params are submitted
        Enrollment.any_instance.stub(:save).and_return(false)
        post :create, {:business_id => @business.to_param, :membership_id => @membership.to_param, :enrollment => {}}
        assigns(:enrollment).should be_a_new(Enrollment)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Enrollment.any_instance.stub(:save).and_return(false)
        post :create, {:business_id => @business.to_param, :membership_id => @membership.to_param, :enrollment => {}}
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested enrollment" do
        enrollment = @membership.create_enrollment! valid_attributes
        # Assuming there are no other businesses in the database, this
        # specifies that the Business created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        Enrollment.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, {:business_id => @business.to_param, :membership_id => @membership.to_param, :enrollment => {'these' => 'params'}}
      end

      it "assigns the requested enrollment as @enrollment" do
        enrollment = @membership.create_enrollment! valid_attributes
        put :update, {:business_id => @business.to_param, :membership_id => @membership.to_param, :enrollment => valid_attributes}
        assigns(:enrollment).should eq(enrollment)
      end

      it "redirects to the enrollment" do
        enrollment = @membership.create_enrollment! valid_attributes
        put :update, {:business_id => @business.to_param, :membership_id => @membership.to_param, :enrollment => valid_attributes}
        response.should redirect_to(business_membership_enrollment_url(@business, @membership, enrollment))
      end
    end

    describe "with invalid params" do
      it "assigns the enrollment as @enrollment" do
        enrollment = @membership.create_enrollment! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Enrollment.any_instance.stub(:save).and_return(false)
        put :update, {:business_id => @business.to_param, :membership_id => @membership.to_param, :enrollment => {}}
        assigns(:enrollment).should eq(enrollment)
      end

      it "re-renders the 'edit' template" do
        enrollment = @membership.create_enrollment! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Enrollment.any_instance.stub(:save).and_return(false)
        put :update, {:business_id => @business.to_param, :membership_id => @membership.to_param, :enrollment => {}}
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested enrollment" do
      enrollment = @membership.create_enrollment! valid_attributes
      expect {
        delete :destroy, {:business_id => @business.to_param, :membership_id => @membership.to_param}
      }.to change(Enrollment, :count).by(-1)
    end

    it "redirects to the enrollments list" do
      enrollment = @membership.create_enrollment! valid_attributes
      delete :destroy, {:business_id => @business.to_param, :membership_id => @membership.to_param, :id => enrollment.to_param}
      response.should redirect_to(business_membership_url(@business, @membership))
    end
  end
end
