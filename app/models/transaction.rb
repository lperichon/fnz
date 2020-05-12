class Transaction < ActiveRecord::Base
  include ActiveModel::Transitions

  before_validation :set_creator
  before_validation :set_business
  before_validation :set_report_at
  before_validation :unset_target

  attr_accessor :skip_update_balances
  after_save :update_balances, unless: :skip_update_balances
  around_destroy :update_balances_around_destroy

  attr_accessor :skip_infer_associations
  after_save :infer_associations, unless: :skip_infer_associations

  attr_accessor :report_at_option

  belongs_to :business
  belongs_to :source, :class_name => "Account"
  belongs_to :target, :class_name => "Account"
  belongs_to :creator, :class_name => "User"

  belongs_to :contact
  belongs_to :agent

  has_one :balance_check, dependent: :destroy, foreign_key: 'difference_transaction_id'

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
  validates :amount, :presence => true, :numericality => {:greater_than_or_equal_to => 0}
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
    ref_date = Time.zone.today.to_date if ref_date.nil?
    self.where("report_at >= ? AND report_at <= ?", ref_date.beginning_of_month, ref_date.end_of_month)
  end

  def self.api_where(q=nil)
    q = {} if q.nil?
    base = self

    if q[:admpart_tag_id]
      if q[:admpart_tag_id] == ""
        q.delete(:admpart_tag_id)
        base = base.where("admpart_tag_id IS NULL")
      else
        if t = Tag.find(q[:admpart_tag_id])
          q[:admpart_tag_id] = t.self_and_descendants.map(&:id)
        end
      end
    end
    if q[:account_id]
      q[:source_id] = q.delete(:account_id)
    end

    if q[:amount_not_eq]
      base = base.where("amount <> ?", q.delete(:amount_not_eq))
    end

    if q[:description]
      base = base.where("description like '%#{q.delete(:description)}%'")
    end

    if q[:smart_query]
      # [TODO] cory js filter logic
      base = base.where("description like '%#{q.delete(:smart_query)}%'")
    end

    base.where(q)
  end

  def set_report_at
    self.report_at = self.transaction_at unless self.report_at.present?
  end

  def cache_tag_total
    if report_at_changed? and report_at_was and admpart_tag
      admpart_tag.update_month_total(report_at_was)
    end
    if admpart_tag_id_changed? and admpart_tag_id_was
      t = Tag.find(admpart_tag_id_was)
      if t
        t.update_month_total(report_at)
      end
    end
    if admpart_tag
      admpart_tag.update_month_total(report_at)
    end
  end

  def update_balances
    if source_id_was != source_id && source_id_was != target_id
      Account.find(source_id_was).update_balance if source_id_was
    end
    if target_id_was != source_id && target_id_was != source_id
      Account.find(target_id_was).update_balance if target_id_was 
    end

    if admpart_tag
      cache_tag_total # for background: delay.cache_tag_total
    end

    source.update_balance
    target.update_balance if target.present?
    installments.each { |installment| installment.update_balance_and_status } if installments.count > 0
    inscriptions.each { |inscription| inscription.update_balance } if inscriptions.count > 0
  end

  # installments automagic
  def infer_associations
    return if business_id.nil?
    if admpart_tag
      # tagged 
      
      if !contact_id.blank? && admpart_tag.in?(Tag.system_tags_tree(business_id,"installment"))
        # with installments
        
        if installments.empty?
          # but no installments
          # find installments and link
          installment = Installment.for_contact(contact_id)
                                   .on_business(business_id)
                                   .on_month(report_at.nil?? transaction_at : report_at ) # fetch installment of report month first, or of transaction month
                                   .first
          if installment
            if agent_id.blank? && installment.agent_id
              update_attribute(:agent_id, installment.agent_id)
              # TODO if installment.agent_id is NULL get contact.padma_teacher 
            end
            # to ensure callbacks that calculate balances, etc.
            InstallmentTransaction.create(
              installment_id: installment.id,
              transaction_id: id
            )
          end
        end
      end
    elsif !installments.empty?
      # not tagged and installments linked

      ref_installment = self.installments.first

      new_attrs = {
        contact_id: ref_installment.try(:membership).try(:contact_id),
        agent_id: ref_installment.agent_id
      }

      if t = Tag.where(business_id: business_id, system_name: "installment").first
        new_attrs.merge!({
          tag_id: t.id,
          admpart_tag_id: t.id
        })
      end

      self.skip_infer_associations = true
      update_attributes(new_attrs)
    end
  end

  def update_balances_around_destroy
    cached_source = source
    cached_target = target
    cached_installments = self.installments.all
    cached_tag = admpart_tag

    yield

    if cached_tag
      cache_tag_total # for background: delay.cache_tag_total
    end
    cached_installments.each { |installment| installment.update_balance_and_status } if cached_installments.count > 0
    cached_source.update_balance if cached_source
    cached_target.update_balance if cached_target
  end

  def unset_target
    if type_changed? && type_was == "Transfer"
      # [TODO] should target.update_balance but at this point i'm still accountable on target. queue it for affter save?
      self.target_id = nil
      self.target = nil
    end
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

  def self.last_updated_at
    self.select("max(transactions.updated_at) as last_update")[0].last_update
  end
end
