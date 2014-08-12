class ImportsController < UserApplicationController
  before_filter :get_business

  def index
    @imports = @business.imports
  end

  def show
    @import = @business.imports.find(params[:id])
  end

  def edit
    @import = @business.imports.find(params[:id])
  end

  def new
    @import = @business.imports.new(params[:import])
  end

  # POST /imports
  # POST /imports.json
  def create
    @import = @business.imports.new(params[:import])
    @import.type = "TransactionImport"

    respond_to do |format|
      if @import.save
        format.html { redirect_to business_import_path(@business, @import), notice: 'Import was successfully created.' }
        format.json { render json: @import, status: :created, location: @import }
      else
        format.html { render action: "new" }
        format.json { render json: @import.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /imports/1
  # PUT /imports/1.json
  def update
    @import = @business.imports.find(params[:id])

    respond_to do |format|
      if @import.update_attributes(params[:import])
        format.html { redirect_to business_import_path(@business, @import), notice: 'Import was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @import.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /imports/1
  # DELETE /imports/1.json
  def destroy
    @import = @business.imports.find(params[:id])
    @import.destroy

    respond_to do |format|
      format.html { redirect_to business_imports_url(@business) }
      format.json { head :no_content }
    end
  end

  def process_csv
    @import = @business.imports.find(params[:id])

    respond_to do |format|
      if @import.status.to_sym == :ready && @import.delay.process && @import.update_attribute(:status, :queued)
        format.html { redirect_to business_import_path(@business, @import), notice: 'Import was successfully queued. Please refresh to see results.' }
      else
        format.html { redirect_to business_import_path(@business, @import), notice: 'Import process failed.' }
      end
    end
  end

  def errors
    @import = @business.imports.find(params[:id])

    # Export Error file for later upload upon correction
    if @import.errors_csv.empty?
      flash[:notice] = I18n.t('transaction.import.success')
      redirect_to business_import_url(@business, @import) #GET
    else
      errFile ="errors_#{Date.today.strftime('%d%b%y')}.csv"
      send_data @import.errors_csv, :type => 'text/csv; charset=iso-8859-1; header=present', :disposition => "attachment; filename=#{errFile}"
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
