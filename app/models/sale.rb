class Sale < ActiveRecord::Base
  belongs_to :business
  belongs_to :contact
  belongs_to :agent
  belongs_to :product

  has_many :sale_transactions
  has_many :transactions, :through => :sale_transactions

  validates :business, :presence => true
  validates :agent, :presence => true
  validates :sold_on, :presence => true

  # Setup accessible (or protected) attributes for your model
  attr_accessible :contact_id, :business_id, :agent_id, :product_id, :transactions_attributes, :sale_transactions_attributes, :sold_on, :padma_contact_id
  accepts_nested_attributes_for :transactions, allow_destroy: true
  accepts_nested_attributes_for :sale_transactions, :reject_if => proc { |s| s['transaction_id'].blank? }

  default_scope order("sold_on DESC")


  def padma_contact_id= padma_contact_id
    unless c = Contact.find_by_padma_id(padma_contact_id)
      padma_contact = PadmaContact.find(padma_contact_id, select: [:first_name, :last_name, :status, :global_teacher_username])
      c = Contact.create(padma_id: padma_contact_id,
                         business_id: self.business_id,
                         name: "#{padma_contact.first_name} #{padma_contact.last_name}",
                         padma_status: padma_contact.status,
                         padma_teacher: padma_contact.global_teacher_username)
    end

    self.contact = c
  end

  def padma_contact_id
    self.contact.try(:padma_id)
  end

  def self.build_from_csv(business, row)
    sale = Sale.new

    product = business.products.find_by_external_id(row[1].to_i)
    agent_id = row[2].gsub!(' ','')
    agent = business.agents.find_by_padma_id(agent_id) # some ids have spaces between
    unless agent
      agent = business.agents.create(:padma_id => agent_id)
    end
    padma_contact = PadmaContact.find_by_kshema_id(row[3])
    contact = Contact.find_by_padma_id(padma_contact.id)

    sale.attributes = {
        :business_id => business.id,
        :agent_id => agent.id,
        :sold_on => DateTime.parse(row[5])
    }

    if contact
      sale.contact = contact
    end

    if product
      sale.product = product
    end

    return sale
  end

  def self.csv_header
    "id,producto_id,instructor_id,persona_id,notes,fecha,created_at,updated_at,precio_in_cents,fecha_pago,pago,school_id,currency,forma_id".split(',')
  end
end
