class Inscription < ActiveRecord::Base
  belongs_to :business
  belongs_to :contact, :touch => true
  belongs_to :payment_type

  has_many :inscription_transactions
  has_many :trans, foreign_key: 'transaction_id', class_name: "Transaction", :through => :inscription_transactions

  validates :value, :numericality =>  {:greater_than_or_equal => 0}
  validates :business, :presence => true
  validates :contact, :presence => true

  # Setup accessible (or protected) attributes for your model
  #attr_accessible :contact_id, :business_id, :payment_type_id, :value, :external_id, :transactions_attributes, :inscription_transactions_attributes, :observations, :balance, :padma_account, :contact_attributes

  include BelongsToPadmaContact

  accepts_nested_attributes_for :trans, allow_destroy: true
  accepts_nested_attributes_for :inscription_transactions, :reject_if => proc { |s| s['transaction_id'].blank? }
  accepts_nested_attributes_for :contact, allow_destroy: true

  def contact_name= name
    self.contact = @business.contacts.find_or_create_by(name: name)
  end

  def update_balance
    self.update_attribute(:balance, calculate_balance)
  end

  def calculate_balance
    trans.where(:state => ['created', 'reconciled']).inject(0) {|balance, tran| balance+tran.sign(self)*tran.amount}
  end

  def balance
    self[:balance] > value ? value : self[:balance]
  end
end
