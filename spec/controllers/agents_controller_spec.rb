require 'rails_helper'

describe AgentsController, :type => :controller do

  # This should return the minimal set of attributes required to create a valid
  # Business. As you add validations to Business, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    {
      :name => "Test Agent"
    }
  end

  before(:each) do
    @business = FactoryBot.create(:business)
    sign_in @business.owner
  end

  describe "GET index" do
    it "assigns all agents as @agents" do
      agent = @business.agents.create! valid_attributes
      get :index, {:business_id => @business.to_param}
      expect(assigns(:agents)).to eq([agent])
    end
  end

  describe "GET show" do
    it "should be successful" do
      agent = @business.agents.create! valid_attributes
      get :show, :business_id => @business.to_param, :id => agent.to_param
      expect(response).to be_success
    end

    it "assigns the requested business as @business" do
      agent = @business.agents.create! valid_attributes
      get :show, {:business_id => @business.to_param, :id => agent.to_param}
      expect(assigns(:agent)).to eq agent
    end
  end

  describe "GET new" do
    it "assigns a new business as @business" do
      get :new, {:business_id => @business.to_param}
      expect(assigns(:agent)).to be_a_new(Agent)
    end
  end

  describe "GET edit" do
    it "assigns the requested business as @business" do
      agent = @business.agents.create! valid_attributes
      get :edit, {:business_id => @business.to_param, :id => agent.to_param}
      expect(assigns(:agent)).to eq(agent)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Agent" do
        expect {
          post :create, {:business_id => @business.to_param, :agent => valid_attributes}
        }.to change(Agent, :count).by(1)
      end

      it "assigns a newly created agent as @agents" do
        post :create, {:business_id => @business.to_param, :agent => valid_attributes}
        expect(assigns(:agent)).to be_a(Agent)
        expect(assigns(:agent)).to be_persisted
      end

      it "redirects to the created agent" do
        post :create, {:business_id => @business.to_param, :agent => valid_attributes}
        expect(response).to redirect_to(business_agent_url(@business,Agent.last))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved agent as @agent" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Agent).to receive(:save).and_return(false)
        post :create, {:business_id => @business.to_param, :agent => {}}
        expect(assigns(:agent)).to be_a_new(Agent)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Agent).to receive(:save).and_return(false)
        post :create, {:business_id => @business.to_param, :agent => {}}
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested agent" do
        agent = @business.agents.create! valid_attributes
        # Assuming there are no other businesses in the database, this
        # specifies that the Business created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        expect_any_instance_of(Agent).to receive(:update_attributes).with({'name' => 'params'})
        put :update, {:business_id => @business.to_param, :id => agent.to_param, :agent => {'name' => 'params'}}
      end

      it "assigns the requested agent as @agent" do
        agent = @business.agents.create! valid_attributes
        put :update, {:business_id => @business.to_param, :id => agent.to_param, :agent => valid_attributes}
        expect(assigns(:agent)).to eq(agent)
      end

      it "redirects to the agent" do
        agent = @business.agents.create! valid_attributes
        put :update, {:business_id => @business.to_param, :id => agent.to_param, :agent => valid_attributes}
        expect(response).to redirect_to(business_agent_url(@business, agent))
      end
    end

    describe "with invalid params" do
      it "assigns the business as @business" do
        agent = @business.agents.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Agent).to receive(:save).and_return(false)
        put :update, {:business_id => @business.to_param, :id => agent.to_param, :agent => {}}
        expect(assigns(:agent)).to eq(agent)
      end

      it "re-renders the 'edit' template" do
        agent = @business.agents.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Agent).to receive(:save).and_return(false)
        put :update, {:business_id => @business.to_param, :id => agent.to_param, :agent => {}}
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested business" do
      agent = @business.agents.create! valid_attributes
      expect {
        delete :destroy, {:business_id => @business.to_param, :id => agent.to_param}
      }.to change(Agent, :count).by(-1)
    end

    it "redirects to the businesses list" do
      agent = @business.agents.create! valid_attributes
      delete :destroy, {:business_id => @business.to_param, :id => agent.to_param}
      expect(response).to redirect_to(business_agents_url(@business))
    end
  end

end
