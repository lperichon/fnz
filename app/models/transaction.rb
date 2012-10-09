class Transaction < ActiveRecord::Base
  include ActiveModel::Transitions

  before_validation :set_creator
  before_validation :set_business
  after_save :update_balances

  belongs_to :business
  belongs_to :source, :class_name => "Account"
  belongs_to :creator, :class_name => "User"

  has_many :taggings
  has_many :tags, :through => :taggings

  has_and_belongs_to_many :sales
  has_and_belongs_to_many :enrollments
  has_and_belongs_to_many :installments

  validates :description, :presence => true
  validates :business, :presence => true
  validates :source, :presence => true
  validates :amount, :presence => true, :numericality => {:greater_than => 0}
  validates :creator, :presence => true

  # Setup accessible (or protected) attributes for your model
  attr_accessible :tag_ids, :description, :business_id, :source_id, :amount, :type, :transaction_at, :target_id, :conversion_rate, :state, :reconciled_at, :sale_ids, :installment_ids, :enrollment_ids

  def update_balances
    source.update_balance
    installments.each { |installment| installment.update_balance } if installments.count > 0
  end

  def set_creator
    self.creator = User.current_user unless creator
  end

  def set_business
    self.business = source.business unless business
  end

  state_machine do
    state :created # first one is initial state
    state :pending
    state :reconciled

    event :reconcile, :timestamp => true do
      transitions :to => :reconciled, :from => :pending
    end
  end

  def self.build_from_csv(business, row)
    transaction = Transaction.new
    amount = BigDecimal.new(row[2])
    type = amount > 0 ? "Credit" : "Debit"
    transaction.attributes = {
        :business_id => business.id,
        :type => type,
        :source_id => business.accounts.find_or_create_by_name(row[0]).id,
        :transaction_at => row[1],
        :amount => amount.abs(),
        :description => row[3]
    }
    return transaction
  end

  def self.csv_header
    "Account,Date,Amount,Description".split(',')
  end
end
