class TransactionRulesController < UserApplicationController
  before_filter :get_business

  def index
    @transaction_rules = @business.transaction_rules
  end

  def edit
    @transaction_rule = @business.transaction_rules.find(params[:id])
  end

  def new
    @transaction_rule = @business.transaction_rules.new(transaction_rule_params)
  end

  # POST /transaction_rules
  # POST /transaction_rules.json
  def create
    @transaction_rule = @business.transaction_rules.new(transaction_rule_params)

    respond_to do |format|
      if @transaction_rule.save
        format.html { redirect_to business_transaction_rules_path(@business), notice: _("Regla creada") }
        format.json { render json: @transaction_rule, status: :created, location: @transaction_rule }
      else
        format.html do
          render action: "new"
        end
        format.json { render json: @transaction_rule.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /transaction_rules/1
  # PUT /transaction_rules/1.json
  def update
    @transaction_rule = @business.transaction_rules.find(params[:id])

    respond_to do |format|
      if @transaction_rule.update_attributes(transaction_rule_params || {})
        format.html { redirect_to business_transaction_rules_path(@business), notice: _("Regla actualizada") }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @transaction_rule.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /transaction_rules/1
  # DELETE /transaction_rules/1.json
  def destroy
    @transaction_rule = @business.transaction_rules.find(params[:id])
    @transaction_rule.destroy

    respond_to do |format|
      format.html { redirect_to business_transaction_rules_url(@business), notice: _("Regla eliminada") }
      format.json { head :no_content }
    end
  end

  private

  def get_business
    @business = Business.find(params[:business_id])
  end

  def transaction_rule_params
    if params[:transaction_rule]
      params.require(:transaction_rule).permit!
    end
  end
end
