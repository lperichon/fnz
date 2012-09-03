require 'spec_helper'

describe ContactsController do

  # This should return the minimal set of attributes required to create a valid
  # Business. As you add validations to Business, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    {
      :name => "Test Contact"
    }
  end

  before(:each) do
    @business = FactoryGirl.create(:business)
    sign_in @business.owner
  end

  describe "GET index" do
    it "assigns all contacts as @contacts" do
      contact = @business.contacts.create! valid_attributes
      get :index, {:business_id => @business.to_param}
      assigns(:contacts).should eq([contact])
    end
  end

  describe "GET show" do
    it "should be successful" do
      contact = @business.contacts.create! valid_attributes
      get :show, :business_id => @business.to_param, :id => contact.to_param
      response.should be_success
    end

    it "assigns the requested business as @business" do
      contact = @business.contacts.create! valid_attributes
      get :show, {:business_id => @business.to_param, :id => contact.to_param}
      assigns(:contact).should == contact
    end
  end

  describe "GET new" do
    it "assigns a new business as @business" do
      get :new, {:business_id => @business.to_param}
      assigns(:contact).should be_a_new(Contact)
    end
  end

  describe "GET edit" do
    it "assigns the requested business as @business" do
      contact = @business.contacts.create! valid_attributes
      get :edit, {:business_id => @business.to_param, :id => @business.to_param}
      assigns(:contact).should eq(contact)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Contact" do
        expect {
          post :create, {:business_id => @business.to_param, :contact => valid_attributes}
        }.to change(Contact, :count).by(1)
      end

      it "assigns a newly created contact as @contacts" do
        post :create, {:business_id => @business.to_param, :contact => valid_attributes}
        assigns(:contact).should be_a(Contact)
        assigns(:contact).should be_persisted
      end

      it "redirects to the created contact" do
        post :create, {:business_id => @business.to_param, :contact => valid_attributes}
        response.should redirect_to(business_contact_url(@business,Contact.last))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved contact as @contact" do
        # Trigger the behavior that occurs when invalid params are submitted
        Contact.any_instance.stub(:save).and_return(false)
        post :create, {:business_id => @business.to_param, :contact => {}}
        assigns(:contact).should be_a_new(Contact)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Contact.any_instance.stub(:save).and_return(false)
        post :create, {:business_id => @business.to_param, :contact => {}}
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested contact" do
        contact = @business.contacts.create! valid_attributes
        # Assuming there are no other businesses in the database, this
        # specifies that the Business created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        Contact.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, {:business_id => @business.to_param, :id => contact.to_param, :contact => {'these' => 'params'}}
      end

      it "assigns the requested contact as @contact" do
        contact = @business.contacts.create! valid_attributes
        put :update, {:business_id => @business.to_param, :id => contact.to_param, :contact => valid_attributes}
        assigns(:contact).should eq(contact)
      end

      it "redirects to the contact" do
        contact = @business.contacts.create! valid_attributes
        put :update, {:business_id => @business.to_param, :id => contact.to_param, :contact => valid_attributes}
        response.should redirect_to(business_contact_url(@business, contact))
      end
    end

    describe "with invalid params" do
      it "assigns the business as @business" do
        contact = @business.contacts.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Contact.any_instance.stub(:save).and_return(false)
        put :update, {:business_id => @business.to_param, :id => contact.to_param, :contact => {}}
        assigns(:contact).should eq(contact)
      end

      it "re-renders the 'edit' template" do
        contact = @business.contacts.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Contact.any_instance.stub(:save).and_return(false)
        put :update, {:business_id => @business.to_param, :id => contact.to_param, :contact => {}}
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested business" do
      contact = @business.contacts.create! valid_attributes
      expect {
        delete :destroy, {:business_id => @business.to_param, :id => contact.to_param}
      }.to change(Contact, :count).by(-1)
    end

    it "redirects to the businesses list" do
      contact = @business.contacts.create! valid_attributes
      delete :destroy, {:business_id => @business.to_param, :id => contact.to_param}
      response.should redirect_to(business_contacts_url(@business))
    end
  end

end
