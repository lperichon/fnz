# @restful_api v0
class Api::V0::CurrentMembershipsController < Api::V0::ApiController
  before_filter :get_scope
  
  ##
  # Returns current membership
  # @url /v0/businesses/:business_id/contacts/:contact_id/current_membership
  # @action GET
  #
  # @required [String] app_key
  # @required [String] business_id padma account id
  # @required [String] contact_id contact padma id
  #
  # @example_request
  # -- show me the membership 1234 for account
  # GET /v0/businesses/account/contacts/1234/current_membership, {business_id: "account", id: "1234"}
  
  #
  # @author Luis Perichon
  def show
    @contact = @business.contacts.find_by_padma_id(params[:contact_id]) if params[:business_id].present?
    @membership = @contact.try(:current_membership)
    render json: @membership, root: false
  end

  def index
    @memberships = @business.memberships.current.includes(:contact, :payment_type, :installments)
    if params[:padma_contact_ids].present?
      @memberships = @memberships.where(contacts: {
        business_id: @business.id, # for query to use contact's [business_id, padma_id] index
        padma_id: params[:padma_contact_ids]
      })
    end
    render json: {:collection => @memberships.map{|m| MembershipSerializer.new(m, :root => false)}.as_json}
  end

  private

  def get_scope
    @business = Business.get_by_padma_id(params[:business_id])
  end
end
