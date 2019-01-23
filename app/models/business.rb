class Business < ActiveRecord::Base
  belongs_to :owner, :class_name => "User"
  has_many :accounts
  has_many :transactions
  has_many :tags
  has_many :contacts
  has_many :agents
  has_many :products
  has_many :imports
  has_many :product_imports
  has_many :sale_imports
  has_many :membership_imports
  has_many :installment_imports
  has_many :payment_types
  has_and_belongs_to_many :users

  validates :name, :presence => true
  validates :owner, :presence => true

  # Setup accessible (or protected) attributes for your model
  attr_accessible :type, :name, :owner_id, :padma_id, :synchronized_at, :send_weekly_reports, :transactions_enabled, :share_enabled, :use_calendar_installments, :currency_code
  
  after_create :initialize_feature_flags
  after_save :link_to_owner

  def link_to_owner
    unless(self.owner.business_ids.include?(self.id))
      self.owner.businesses << self
    end
  end

  def padma
    PadmaAccount.find(padma_id) if padma_id
  end

  def initialize_feature_flags
    if type == "School"
      update_attributes({
        :transactions_enabled => false,
        :share_enabled => true
      })
    else
      update_attributes({
        :transactions_enabled => true,
        :share_enabled => false
      })
    end
  end

  def self.get_by_padma_id(padma_id)
    b = self.find_by_padma_id(padma_id)
    if b.nil?
      b = School.new(padma_id: padma_id)
      begin
        PadmaAccountsSynchronizer.new(b).sync
      rescue
        b = nil
      end
    end
    b
  end

end
