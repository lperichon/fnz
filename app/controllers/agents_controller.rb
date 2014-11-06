class AgentsController < UserApplicationController
  before_filter :get_business

  def index
    @agents = @business.agents.enabled
  end

  def show
    @agent = @business.agents.find(params[:id])
  end

  def edit
    @agent = @business.agents.find(params[:id])
    @padma_users = @business.try(:padma).try(:users) || []
  end

  def new
    @agent = @business.agents.new(params[:agent])
    @padma_users = @business.try(:padma).try(:users) || []
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
        format.html {
        	@padma_users = @business.try(:padma).try(:users) 
        	render action: "new" 
        }
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
    @business = get_context.find(params[:business_id])
  end

  def get_context
    @context = nil
    if current_user.admin?
      @context = Business
    else
      @context = current_user.businesses
    end
    @context
  end

end
