class Transaction < ActiveRecord::Base
  include ActiveModel::Transitions

  before_validation :set_creator
  before_validation :set_business
  before_validation :set_report_at
  after_save :update_balances
  around_destroy :update_balances_around_destroy

  attr_accessor :report_at_option

  belongs_to :business
  belongs_to :source, :class_name => "Account"
  belongs_to :target, :class_name => "Account"
  belongs_to :creator, :class_name => "User"

  belongs_to :contact
  belongs_to :agent

  def source
    Account.unscoped { super }
  end

  def source_name
    source.name
  end

  def target_name
    target.name
  end

  def target
    Account.unscoped { super }
  end

  has_many :taggings
  has_many :tags, :through => :taggings

  belongs_to :admpart_tag, class_name: "Tag"
  before_save :set_admpart_tag

  has_and_belongs_to_many :sales
  has_and_belongs_to_many :enrollments
  has_and_belongs_to_many :installments
  has_and_belongs_to_many :inscriptions

  validates :description, :presence => true
  validates :business, :presence => true
  validates :source, :presence => true
  validates :amount, :presence => true, :numericality => {:greater_than => 0}
  validates :creator, :presence => true
  validates :transaction_at, :presence => true
  validates :report_at, :presence => true

  # Setup accessible (or protected) attributes for your model
  attr_accessible :tag_id, :tag_ids, :description, :business_id, :source_id, :amount, :type, :transaction_at, :target_id, :conversion_rate, :state, :reconciled_at, :sale_ids, :installment_ids, :enrollment_ids, :creator_id, :report_at, :report_at_option, :inscription_ids, :contact_id, :agent_id, :admpart_tag_id 

  scope :untagged, includes(:taggings).where("taggings.tag_id is null")

  scope :credits, where(:type => "Credit")
  scope :debits, where(:type => "Debit")

  def tag_id= id
    self.tag_ids = [id]
  end

  def tag_id
    self.tags.first.try(:id)
  end

  def tag
    self.tags.first
  end

  def self.to_report_on_month(ref_date)
    ref_date = Time.zone.today if ref_date.nil?
    self.where("report_at >= ? AND report_at <= ?", ref_date.to_time.beginning_of_month, ref_date.to_time.end_of_month)
  end

  def set_report_at
    self.report_at = self.transaction_at unless self.report_at.present?
  end

  def update_balances
    source.update_balance
    target.update_balance if target.present?
    installments.each { |installment| installment.update_balance_and_status } if installments.count > 0
    inscriptions.each { |inscription| inscription.update_balance } if inscriptions.count > 0
  end

  def update_balances_around_destroy
    cached_installments = self.installments.all
    yield
    cached_installments.each { |installment| installment.update_balance_and_status } if cached_installments.count > 0
  end

  def set_creator
    self.creator = User.current_user unless creator
  end

  def set_business
    if source
      self.business = source.business unless business
    end
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

    state = row[7]
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

    # Agent
    unless row[5].blank?
      transaction.agent_id = business.agents.enabled.where(padma_id: row[5]).first
    end

    # Contact
    unless row[6].blank?
      # by name
      transaction.contact_id = business.contacts.where(name: row[6].strip).first.try(:id)
      if transaction.contact_id.nil?
        # by id
        transaction.contact_id = business.contacts.get_by_padma_id(row[6].strip).try(:id)
        if transaction.contact_id.nil?
          raise "couldnt find contact"
        end
      end
    end

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
    "Account,Date,Amount,Description,Tags,Agent,Contact,State".split(',')
  end

  def set_admpart_tag
    self.admpart_tag_id = self.tag_id
  end

  def self.update_each_admpart_tag
    self.all.each{|t| t.update_column(:admpart_tag_id, t.taggings.first.try(:tag_id)) }
  end
end
