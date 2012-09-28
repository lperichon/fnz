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

  private

  def get_business
    @business = current_user.businesses.find(params[:business_id])
  end

end
