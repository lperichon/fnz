class Sale < ActiveRecord::Base
  belongs_to :business
  belongs_to :contact
  belongs_to :agent
  belongs_to :product

  has_many :sale_transactions
  has_many :trans, foreign_key: 'transaction_id', class_name: "Transaction", :through => :sale_transactions

  validates :business, :presence => true
  validates :agent, :presence => true
  validates :sold_on, :presence => true

  # Setup accessible (or protected) attributes for your model
  #attr_accessible :contact_id, :business_id, :agent_id, :product_id, :transactions_attributes, :sale_transactions_attributes, :sold_on, :external_id
  accepts_nested_attributes_for :trans, allow_destroy: true
  accepts_nested_attributes_for :sale_transactions, :reject_if => proc { |s| s['transaction_id'].blank? }
  alias_method :transactions, :trans

  scope :this_month, -> { where {(sold_on.gteq Date.today.beginning_of_month.beginning_of_day) & (sold_on.lteq Date.today.end_of_month.end_of_day)} }
  default_scope { order("sold_on DESC") }

  include BelongsToPadmaContact

  def self.build_from_csv(business, row)
    return if Sale.find_by_external_id(row[0].to_i)

    product = business.products.find_by_external_id(row[1].to_i)
    agent_id = row[2].gsub!(' ','')
    agent = business.agents.find_by_padma_id(agent_id) # some ids have spaces between
    unless agent
      agent_name = agent_id.blank? ? "Unknown" : agent_id.gsub('.',' ').titleize
      agent = business.agents.create(:padma_id => agent_id, :name => agent_name)
    end

    padma_contact = nil
    contact = nil
    unless row[3].blank?
      padma_contact = PadmaContact.find_by_kshema_id(row[3])
      contact = Contact.find_or_create_by(:padma_id => padma_contact.id,
                                                 :business_id => business.id,
                                                 :name => "#{padma_contact.first_name} #{padma_contact.last_name}".strip,
                                                 :padma_status => padma_contact.status,
                                                 :padma_teacher => padma_contact.global_teacher_username)
    end

    sale_date = DateTime.parse(row[5])

    sale_attributes = {
        :business_id => business.id,
        :agent_id => agent.id,
        :sold_on => sale_date,
        :external_id => row[0].to_i
    }

    if contact
      sale_attributes[:contact_id] = contact.id
    end

    if product
      sale_attributes[:product_id] = product.id
    end

    unless row[10].blank? || row[10] == 'false' || row[8].to_i <= 0
    	#paid installment, create correspondig transaction
    	transaction_date = row[9].present? ? Date.parse(row[9]) : sale_date
    	transaction_attrs = {
    		:transaction_at => transaction_date,
    		:amount => row[8].to_f/100.0,
    		:source_id => business.accounts.first.id,
    		:business_id => business.id,
    		:description => "Payment - #{contact.try(:name)} - #{product.try(:name)}",
      		:type => "Credit",
      		:creator_id => business.owner_id
      	}

      	sale_attributes[:transactions_attributes] = [transaction_attrs]
    end

    sale = Sale.new(sale_attributes)

    return sale
  end

  def self.csv_header
    "id,producto_id,instructor_id,persona_id,notes,fecha,created_at,updated_at,precio_in_cents,fecha_pago,pago,school_id,currency,forma_id".split(',')
  end

  def pending?
    !transactions.empty? && transactions.any? { |t| t.pending? }
  end

  def complete?
    !transactions.empty? && transactions.all? { |t| t.created? || t.reconciled? }
  end

  def status
    if pending?
      :pending
    elsif complete?
      :complete
    else
      :incomplete
    end
  end

end
