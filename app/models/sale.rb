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
end
