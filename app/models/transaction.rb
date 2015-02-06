class Transaction < ActiveRecord::Base
  include ActiveModel::Transitions

  before_validation :set_creator
  before_validation :set_business
  before_validation :set_report_at
  after_save :update_balances
  after_destroy :update_balances

  belongs_to :business
  belongs_to :source, :class_name => "Account"
  belongs_to :target, :class_name => "Account"
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
  validates :transaction_at, :presence => true
  validates :report_at, :presence => true

  # Setup accessible (or protected) attributes for your model
  attr_accessible :tag_ids, :description, :business_id, :source_id, :amount, :type, :transaction_at, :target_id, :conversion_rate, :state, :reconciled_at, :sale_ids, :installment_ids, :enrollment_ids, :creator_id, :report_at

  scope :untagged, includes(:taggings).where("taggings.tag_id is null")

  scope :credits, where(:type => "Credit")

  def set_report_at
    self.report_at = self.transaction_at unless self.report_at.present?
  end

  def update_balances
    source.update_balance
    target.update_balance if target.present?
    installments.each { |installment| installment.update_balance_and_status } if installments.count > 0
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

    state = row[5]
    unless state.blank?
    	state = state.downcase
    end

    transaction.attributes = {
        :business_id => business.id,
        :type => type,
        :source_id => business.accounts.find_or_create_by_name(row[0]).id,
        :transaction_at => row[1],
        :amount => amount.abs(),
        :description => row[3],
        :creator_id => business.owner_id,
        :state => ['created', 'pending', 'reconciled'].include?(state) ? state : 'created'
    }

    tags_str = row[4]
    unless tags_str.blank?
      tags_str.split(';').each do |tag_name|
        tag = Tag.find_or_create_by_business_id_and_name(business_id: business.id, name: tag_name)
        transaction.tags << tag
      end
    end
    return transaction
  end

  def self.csv_header
    "Account,Date,Amount,Description,Tags".split(',')
  end
end
