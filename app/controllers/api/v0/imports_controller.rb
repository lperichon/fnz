# @restful_api v0
class Api::V0::ImportsController < Api::V0::ApiController

  before_filter :get_business, :only => :create
  
  ##
  # Returns status of an import
  # Available statuses are:
  #   * :ready
  #   * :working
  #   * :finished
  # @url /v0/imports/:id
  # @action GET
  #
  # @required [String] app_key
  # @required [String] id import id
  #
  # @example_request
  # -- show me the status of the import 1234
  # GET /v0/imports/1234, {id: "1234"}
  # @example response {status: 'working', failed_rows: 2, imported_rows: 10}
  #
  # @response_field [String] status status of the current import [:ready, :working, :finished]
  # @response_field [Integer] failed_rows number of rows that have already failed
  # @response_field [Integer] imported_rows number of rows that have already been imported
  #
  # @author Luis Perichon
  def show
    import = Import.find(params[:id])

    if import.nil?
      render json: {message: "Import not found"}.to_json, status: 404
    else
      render json: {status: import.status,
                    failed_rows: 0, # TODO: import.failed_rows.count,
                    failed_rows_csv: nil, #TODO: failed_rows_api_v0_import_url(import, format: :csv),
                    imported_ids: 0}.to_json, #TODO: import.imported_ids.count}.to_json,
             status: 200
    end
  end

  ##
  # @url /api/v0/imports
  # @action POST
  #
  # @required [String] app_key
  # @required import[object] valid values: Product
  # @required import[csv_file] CSV file
  # @required import[headers]
  #           valid values for Product
  #
  # @required import[padma_id]
  #
  # @response_field id Import id
  #
  def create
    if @business

      @import = initialize_import

      if @import.save
        @import.delay.process
        render json: { id: @import.id }, status: 201
      else
        render json: { error: 'couldnt create import'}, status: 400
      end
    else
      render json: { error: 'no account with this account_name'}, status: 400
    end
  end
  
  ##
  # Returns a CSV file with the import errors
  # @url /v0/imports/:id/failed_rows.csv
  # @action GET
  #
  # @required [String] id import id
  #
  # @example_request
  # GET /v0/imports/1234/failed_errors.csv, {id: "1234"}
  # @example response { CSV }
  #
  # @response_field [CSV] csv file with the errors that occurred during import
  #
  def failed_rows
    @import = Import.find(params[:id])

    if @import.nil?
      render json: { message: "Import not found"}.to_json,
             status: 404
    elsif @import.status.to_sym != :finished
      render json: { message: "Import not finished"}.to_json,
             status: 400
    else
      respond_to do |format|
        format.csv do
          send_data @import.failed_rows_to_csv,
                    type: 'text/csv',
                    disposition: "attachment; filename=import_errors.csv"
        end
      end
    end
  end

  private

  def initialize_import
    ot = params[:import].delete(:object)
    scope = case ot
    when 'Product', 'Sale', 'Membership', 'Installment'
      @business.send("#{ot.underscore}_imports")
    else
      @business.imports
    end
    scope.new(params[:import])
  end


  def get_business
    if params[:import]
      padma_id = params[:import].delete(:padma_id)
      @business = Business.find_by_padma_id(padma_id)
      unless @business
        padma_account = PadmaAccount.find(padma_id)
        padma_user = padma_account.admin
        owner = User.find_or_create_by_drc_uid(drc_uid: padma_user.username, :email => padma_user.username + "@metododerose.org", :password => Devise.friendly_token[0,20])
        @business = School.create!(owner_id: owner.id, padma_id: padma_id, name: padma_id.titleize)
      end
      @business
    end
  end


end
