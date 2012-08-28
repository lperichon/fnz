require 'spec_helper'

describe TagsController do

  # This should return the minimal set of attributes required to create a valid
  # Business. As you add validations to Business, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    {
      :keyword => "Test Tag"
    }
  end

  before(:each) do
    @business = FactoryGirl.create(:business)
    sign_in @business.owner
  end

  describe "GET index" do
    it "assigns all tags as @tags" do
      tag = @business.tags.create! valid_attributes
      get :index, {:business_id => @business.to_param}
      assigns(:tags).should eq([tag])
    end
  end

  describe "GET show" do
    it "should be successful" do
      tag = @business.tags.create! valid_attributes
      get :show, :business_id => @business.to_param, :id => tag.to_param
      response.should be_success
    end

    it "assigns the requested business as @business" do
      tag = @business.tags.create! valid_attributes
      get :show, {:business_id => @business.to_param, :id => tag.to_param}
      assigns(:tag).should == tag
    end
  end

  describe "GET new" do
    it "assigns a new business as @business" do
      get :new, {:business_id => @business.to_param}
      assigns(:tag).should be_a_new(Tag)
    end
  end

  describe "GET edit" do
    it "assigns the requested business as @business" do
      tag = @business.tags.create! valid_attributes
      get :edit, {:business_id => @business.to_param, :id => @business.to_param}
      assigns(:tag).should eq(tag)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Tag" do
        expect {
          post :create, {:business_id => @business.to_param, :tag => valid_attributes}
        }.to change(Tag, :count).by(1)
      end

      it "assigns a newly created tag as @tags" do
        post :create, {:business_id => @business.to_param, :tag => valid_attributes}
        assigns(:tag).should be_a(Tag)
        assigns(:tag).should be_persisted
      end

      it "redirects to the created tag" do
        post :create, {:business_id => @business.to_param, :tag => valid_attributes}
        response.should redirect_to(business_tag_url(@business,Tag.last))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved tag as @tag" do
        # Trigger the behavior that occurs when invalid params are submitted
        Tag.any_instance.stub(:save).and_return(false)
        post :create, {:business_id => @business.to_param, :tag => {}}
        assigns(:tag).should be_a_new(Tag)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Tag.any_instance.stub(:save).and_return(false)
        post :create, {:business_id => @business.to_param, :tag => {}}
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested tag" do
        tag = @business.tags.create! valid_attributes
        # Assuming there are no other businesses in the database, this
        # specifies that the Business created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        Tag.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, {:business_id => @business.to_param, :id => tag.to_param, :tag => {'these' => 'params'}}
      end

      it "assigns the requested tag as @tag" do
        tag = @business.tags.create! valid_attributes
        put :update, {:business_id => @business.to_param, :id => tag.to_param, :tag => valid_attributes}
        assigns(:tag).should eq(tag)
      end

      it "redirects to the tag" do
        tag = @business.tags.create! valid_attributes
        put :update, {:business_id => @business.to_param, :id => tag.to_param, :tag => valid_attributes}
        response.should redirect_to(business_tag_url(@business, tag))
      end
    end

    describe "with invalid params" do
      it "assigns the business as @business" do
        tag = @business.tags.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Tag.any_instance.stub(:save).and_return(false)
        put :update, {:business_id => @business.to_param, :id => tag.to_param, :tag => {}}
        assigns(:tag).should eq(tag)
      end

      it "re-renders the 'edit' template" do
        tag = @business.tags.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Tag.any_instance.stub(:save).and_return(false)
        put :update, {:business_id => @business.to_param, :id => tag.to_param, :tag => {}}
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested business" do
      tag = @business.tags.create! valid_attributes
      expect {
        delete :destroy, {:business_id => @business.to_param, :id => tag.to_param}
      }.to change(Tag, :count).by(-1)
    end

    it "redirects to the businesses list" do
      tag = @business.tags.create! valid_attributes
      delete :destroy, {:business_id => @business.to_param, :id => tag.to_param}
      response.should redirect_to(business_tags_url(@business))
    end
  end

end
