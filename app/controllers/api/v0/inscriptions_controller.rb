# @restful_api v0
class Api::V0::InscriptionsController < Api::V0::ApiController

  before_filter :get_business, :only => :create
  
  ##
  # Returns status of an inscription
  # @url /v0/inscriptions/:id
  # @action GET
  #
  # @required [String] app_key
  # @required [String] id import id
  #
  # @example_request
  # -- show me the status of the import 1234
  # GET /v0/imports/1234, {id: "1234"}
  # @example response {value: 100.0, balance: 100.0}
  #
  # @response_field [Float] value value of the inscription
  # @response_field [Float] balance paid amount
  #
  # @author Luis Perichon
  def show
    inscription = Inscription.find(params[:id])

    if inscription.nil?
      render json: {message: "Inscription not found"}.to_json, status: 404
    else
      render json: {value: inscription.value,
                    balance: inscription.balance}.to_json,
             status: 200
    end
  end

  ##
  # @url /api/v0/inscriptions
  # @action POST
  #
  # @required [String] app_key
  
  # @required inscription[business_id]
  # @required inscription[contact_name]
  # @required inscription[value]
  #
  # @response_field id Import id
  #
  def create
    if @business
      @inscription = @business.inscriptions.new(params[:inscription])
      if @inscription.save
        render json: { id: @inscription.id }, status: 201
      else
        render json: { error: 'couldnt create import'}, status: 400
      end
    else
      render json: { error: 'no account with this account_name'}, status: 400
    end
  end

  private

  def get_business
    if params[:inscription]
      business_id = params[:inscription].delete(:business_id)
      @business = Business.find(business_id)
      
      @business
    end
  end


end
