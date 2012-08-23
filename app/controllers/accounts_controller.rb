class AccountsController < ApplicationController
  before_filter :authenticate_user!

  before_filter :get_business

  def index
    @accounts = @business.accounts
  end

  def show
    @account = @business.accounts.find(params[:id])
  end

  def edit
    @account = @business.accounts.find(params[:id])
  end

  def new
    @account = @business.accounts.new(params[:account])
  end

  # POST /accounts
  # POST /accounts.json
  def create
    @account = @business.accounts.new(params[:account])

    respond_to do |format|
      if @account.save
        format.html { redirect_to business_account_path(@business, @account), notice: 'Account was successfully created.' }
        format.json { render json: @account, status: :created, location: @account }
      else
        format.html { render action: "new" }
        format.json { render json: @account.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /accounts/1
  # PUT /accounts/1.json
  def update
    @account = @business.accounts.find(params[:id])

    respond_to do |format|
      if @account.update_attributes(params[:account])
        format.html { redirect_to business_account_path(@business, @account), notice: 'Account was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @account.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /accounts/1
  # DELETE /accounts/1.json
  def destroy
    @account = @business.accounts.find(params[:id])
    @account.destroy

    respond_to do |format|
      format.html { redirect_to business_accounts_url(@business) }
      format.json { head :no_content }
    end
  end

  private

  def get_business
    @business = current_user.businesses.find(params[:business_id])
  end

end
