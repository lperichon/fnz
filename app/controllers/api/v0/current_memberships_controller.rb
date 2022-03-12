# @restful_api v0
class Api::V0::CurrentMembershipsController < Api::V0::ApiController
  before_filter :get_business

  skip_before_action :verify_authenticity_token
  
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

  ##
  # Updates current membership
  # * if current_membership exists AND external_id matches, attributes are updated
  # * if current_membership exists AND external_id DOESNT match, closes previous and creates new
  # * else creates new
  #
  #
  # @url /v0/businesses/:business_id/contacts/:contact_id/current_membership
  # @action PUT
  #
  # @required [Hash] membership
  # @required [String] membership[external_id]
  # @required [String] membership[name]
  # @required [Integer] membership[value_cents]
  # @required [Date] membership[begins_on]
  # @optional [Date] membership[ends_on]
  # @required [Date] membership[payment_type_name]
  #
  # @required [String] app_key
  # @required [String] business_id padma account id
  # @required [String] contact_id contact padma id
  def update
    @contact = @business.contacts.find_by_padma_id(params[:contact_id]) if params[:business_id].present?

    if (@membership = (@contact.try(:current_membership) || @contact.memberships.where(external_id: membership_params["external_id"]).first ) )
      if @membership.external_id == membership_params[:external_id]
        # update
        @success = @membership.update(membership_params)
      else
        # close and create new
        @membership.update(closed_on: membership_params[:starts_on])

        @membership = Membership.new(membership_params.merge({business: @business, contact_id: @contact.id}))
        if membership_params[:payment_type_name]
          # requires for business to already be set
          @membership.payment_type_name = membership_params[:payment_type_name]
        end
        @success = @membership.save
      end
    else
      # create
      @membership = Membership.new(membership_params.merge({business: @business, contact_id: @contact.id}))
      if membership_params[:payment_type_name]
        # requires for business to already be set
        @membership.payment_type_name = membership_params[:payment_type_name]
      end
      @success = @membership.save
    end

    if @success && @membership
      render json: @membership, root: false, status: 201
    else
      render json: {message: @membership.errors}, status: 400
    end
  end

  def index
    Appsignal.instrument("build_memberships_scope") do
      @memberships = @business.memberships.current.includes(:contact, :payment_type, :installments).unscope(:order)
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

  def membership_params
    params.require(:membership).permit(
      :external_id,
      :name,
      :begins_on,
      :ends_on,
      :value_cents,
      :payment_type_name
    )
  end

  def get_business
    Appsignal.instrument("get_business") do
      @business = Business.get_by_padma_id(params[:business_id])
    end
  end
end
