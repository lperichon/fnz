require 'rails_helper'

describe MembershipsController, :type => :controller do

  # This should return the minimal set of attributes required to create a valid
  # Business. As you add validations to Business, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    {
        :contact_id => @contact.id,
        :business_id => @business.id,
        :begins_on => Date.today.beginning_of_month,
        :ends_on => 11.months.from_now.end_of_month,
        :monthly_due_day => 10,
        :value => 100
    }
  end

  def attributes_with_padma_contact_id
    ret = valid_attributes
    ret.delete(:contact_id)
    ret[:padma_contact_id] = 'contact-id'
    ret
  end

  before(:each) do

	  CrmLegacyContact.stub(:find).and_return(
      CrmLegacyContact.new(first_name: 'blah', last_name: 'balh', global_teacher_username: 'luis.perichon', status: 'student')
    )

    @business = FactoryBot.create(:school)
    @contact = FactoryBot.create(:contact, :business => @business)
    @agent = FactoryBot.create(:agent, :business => @business)
    @user = @business.owner
    sign_in @user
  end

  describe "GET business memberships index" do
    it "assigns all memberships as @memberships" do
      membership = @business.memberships.create! valid_attributes
      get :index, {:business_id => @business.to_param}
      expect(assigns(:memberships)).to include membership
    end
  end

  describe "GET show" do
    it "should be successful" do
      membership = @business.memberships.create! valid_attributes
      get :show, :business_id => @business.to_param, :id => membership.to_param
      expect(response).to be_success
    end

    it "assigns the requested membership as @membership" do
      membership = @business.memberships.create! valid_attributes
      get :show, :business_id => @business.to_param, :id => membership.to_param
      expect(assigns(:membership)).to eq membership
    end
  end

  describe "GET new" do
    it "assigns a new membership as @membership" do
      get :new, :business_id => @business.to_param
      expect(assigns(:membership)).to be_a_new(Membership)
    end
  end

  describe "GET edit" do
    it "assigns the requested membership as @membership" do
      membership = @business.memberships.create! valid_attributes
      get :edit, :business_id => @business.to_param, :id => membership.to_param
      expect(assigns(:membership)).to eq(membership)
    end
  end

  describe "POST create" do
    describe "with params with padma_id" do
      it "creates a new Membership" do
        expect {
          post :create, { business_id: @business.to_param,
                          membership: attributes_with_padma_contact_id }
        }.to change(Membership, :count).by(1)
      end
      describe "if 2 contacts exist in different business" do
        before do
          pcid = attributes_with_padma_contact_id[:padma_contact_id]
          @other_contact = FactoryBot.create(:contact, padma_id: pcid)
          @my_contact = FactoryBot.create(:contact,
                                           padma_id: pcid,
                                           :business => @business)
        end
        it "creates membership of current business" do
          expect {
            post :create, { business_id: @business.to_param,
                            membership: attributes_with_padma_contact_id }
          }.to change{ @my_contact.memberships.count }.by(1)
        end
      end
    end

    describe "with valid params" do
      it "creates a new Membership" do
        expect {
          post :create, {:business_id => @business.to_param, :membership => valid_attributes}
        }.to change(Membership, :count).by(1)
      end

      it "assigns a newly created membership as @membership" do
        post :create, {:business_id => @business.to_param, :membership => valid_attributes}
        expect(assigns(:membership)).to be_a(Membership)
        expect(assigns(:membership)).to be_persisted
      end

      it "assigns the current user to the created membership as creator" do
        post :create, {:business_id => @business.to_param, :membership => valid_attributes}
      end

      it "redirects to the created membership" do
        post :create, {:business_id => @business.to_param, :membership => valid_attributes}
        expect(response).to redirect_to(business_membership_url(@business, Membership.last))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved membership as @membership" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Membership).to receive(:save).and_return(false)
        post :create, {:business_id => @business.to_param, :membership => {}}
        expect(assigns(:membership)).to be_a_new(Membership)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Membership).to receive(:save).and_return(false)
        post :create, {:business_id => @business.to_param, :membership => {}}
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested membership" do
        membership = @business.memberships.create! valid_attributes
        # Assuming there are no other businesses in the database, this
        # specifies that the Business created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        expect_any_instance_of(Membership).to receive(:update_attributes).with({'value' => 'params'})
        put :update, {:business_id => @business.to_param, :id => membership.to_param, :membership => {'value' => 'params'}}
      end

      it "assigns the requested membership as @membership" do
        membership = @business.memberships.create! valid_attributes
        put :update, {:business_id => @business.to_param, :id => membership.to_param, :membership => valid_attributes}
        expect(assigns(:membership)).to eq(membership)
      end

      it "redirects to the membership" do
        membership = @business.memberships.create! valid_attributes
        put :update, {:business_id => @business.to_param, :id => membership.to_param, :membership => valid_attributes}
        expect(response).to redirect_to(business_membership_url(@business, membership))
      end
    end

    describe "with invalid params" do
      it "assigns the membership as @membership" do
        membership = @business.memberships.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Membership).to receive(:save).and_return(false)
        put :update, {:business_id => @business.to_param, :id => membership.to_param, :membership => {}}
        expect(assigns(:membership)).to eq(membership)
      end

      it "re-renders the 'edit' template" do
        membership = @business.memberships.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Membership).to receive(:save).and_return(false)
        put :update, {:business_id => @business.to_param, :id => membership.to_param, :membership => {}}
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested membership" do
      membership = @business.memberships.create! valid_attributes
      expect {
        delete :destroy, {:business_id => @business.to_param, :id => membership.to_param}
      }.to change(Membership, :count).by(-1)
    end

    it "redirects to the businesses list" do
      membership = @business.memberships.create! valid_attributes
      delete :destroy, {:business_id => @business.to_param, :id => membership.to_param}
      expect(response).to redirect_to(business_memberships_url(@business))
    end
  end

end
