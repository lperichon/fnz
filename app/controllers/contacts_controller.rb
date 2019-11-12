class ContactsController < UserApplicationController
  before_filter :get_business

  def index
    @contacts = @business.contacts
  end

  def show
    param_is_padma_id = (false if Float(params[:id]) rescue true)
    if param_is_padma_id
      @contact = @business.contacts.get_by_padma_id(params[:id])
    else
      @contact = @business.contacts.find(params[:id])
    end
    @memberships = @contact.memberships.where(business_id: @business.id)
    if @business.transactions_enabled?
      @transactions = @business.transactions.where(contact_id: @contact.id).order("transaction_at DESC")
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
    param_is_padma_id = (false if Float(params[:business_id]) rescue true)
    if param_is_padma_id
      @business = get_context.get_by_padma_id(params[:business_id])
    else
      @business = get_context.find(params[:business_id])
    end
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
