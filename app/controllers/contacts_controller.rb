class ContactsController < ApplicationController
  before_filter :authenticate_user!

  before_filter :get_business

  def index
    @contacts = @business.contacts
  end

  def show
    @contact = @business.contacts.find(params[:id])
  end

  def edit
    @contact = @business.contacts.find(params[:id])
  end

  def new
    @contact = @business.contacts.new(params[:contact])
  end

  # POST /contacts
  # POST /contacts.json
  def create
    @contact = @business.contacts.new(params[:contact])

    respond_to do |format|
      if @contact.save
        format.html { redirect_to business_contact_path(@business, @contact), notice: 'Contact was successfully created.' }
        format.json { render json: @contact, status: :created, location: @contact }
      else
        format.html { render action: "new" }
        format.json { render json: @contact.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /contacts/1
  # PUT /contacts/1.json
  def update
    @contact = @business.contacts.find(params[:id])

    respond_to do |format|
      if @contact.update_attributes(params[:contact])
        format.html { redirect_to business_contact_path(@business, @contact), notice: 'Contact was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @contact.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /contacts/1
  # DELETE /contacts/1.json
  def destroy
    @contact = @business.contacts.find(params[:id])
    @contact.destroy

    respond_to do |format|
      format.html { redirect_to business_contacts_url(@business) }
      format.json { head :no_content }
    end
  end

  private

  def get_business
    @business = current_user.businesses.find(params[:business_id])
  end

end
