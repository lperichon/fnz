class AgentsController < ApplicationController
  before_filter :authenticate_user!

  before_filter :get_business

  def index
    @agents = @business.agents
  end

  def show
    @agent = @business.agents.find(params[:id])
  end

  def edit
    @agent = @business.agents.find(params[:id])
  end

  def new
    @agent = @business.agents.new(params[:agent])
  end

  # POST /agents
  # POST /agents.json
  def create
    @agent = @business.agents.new(params[:agent])

    respond_to do |format|
      if @agent.save
        format.html { redirect_to business_agent_path(@business, @agent), notice: 'Agent was successfully created.' }
        format.json { render json: @agent, status: :created, location: @agent }
      else
        format.html { render action: "new" }
        format.json { render json: @agent.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /agents/1
  # PUT /agents/1.json
  def update
    @agent = @business.agents.find(params[:id])

    respond_to do |format|
      if @agent.update_attributes(params[:agent])
        format.html { redirect_to business_agent_path(@business, @agent), notice: 'Agent was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @agent.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /agents/1
  # DELETE /agents/1.json
  def destroy
    @agent = @business.agents.find(params[:id])
    @agent.destroy

    respond_to do |format|
      format.html { redirect_to business_agents_url(@business) }
      format.json { head :no_content }
    end
  end

  private

  def get_business
    @business = current_user.businesses.find(params[:business_id])
  end

end
