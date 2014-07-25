class ContactsController < UserApplicationController
  before_filter :get_business

  def index
    @contacts = @business.contacts
  end

  def show
    param_is_padma_id = (false if Float(params[:id]) rescue true)
    if param_is_padma_id
      @contact = @business.contacts.find_by_padma_id(params[:id])
    else
      @contact = @business.contacts.find(params[:id])
    end
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
        format.json { render json: @contact, status: :created, location: business_contact_path(@business,@contact) }
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
    Rails.logger.debug params[:business_id]
    param_is_padma_id = (false if Float(params[:business_id]) rescue true)
    if param_is_padma_id
      @business = current_user.businesses.find_by_padma_id(params[:business_id])
    else
      @business = current_user.businesses.find(params[:business_id])
    end
  end

end
