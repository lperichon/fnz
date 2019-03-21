# @restful_api v0
class Api::V0::CurrentMembershipsController < Api::V0::ApiController
  before_filter :get_business
  
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
    Appsignal.instrument("build_memberships_scope") do
      @memberships = @business.memberships.current.includes(:contact, :payment_type, :installments)
      if params[:padma_contact_ids].present?
        @memberships = @memberships.where(contacts: {
          business_id: @business.id, # for query to use contact's [business_id, padma_id] index
          padma_id: params[:padma_contact_ids]
        })
      end
    end
    Appsignal.instrument("serialize_memberships") do
      @json = @memberships.map do |m|
        {
          value: m.value,
          begins_on: m.begins_on,
          ends_on: m.ends_on,
          payment_type: m.payment_type.try(:name),
          padma_contact_id: m.contact.try(:padma_id),
          name: m.name,
          installments: m.installments
        }
      end
    end
    render json: {:collection => @json }
  end

  private

  def get_business
    Appsignal.instrument("get_business") do
      @business = Business.get_by_padma_id(params[:business_id])
    end
  end
end
