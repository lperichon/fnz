class Tag < ActiveRecord::Base
  acts_as_nested_set
  include TheSortableTree::Scopes

  belongs_to :business

  has_many :taggings, :dependent => :destroy
  has_many :transactions, through: :taggings

  validates :name, :presence => true
  validates :business, :presence => true

  default_scope order('name ASC')

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :business_id, :admpart_section, :system_name

  validates_uniqueness_of :name, :scope => :business_id
  validates_length_of :name, :maximum => 255

  VALID_SYSTEM_NAMES = %W(installment sale enrollment)
  validates :system_name,
            allow_blank: true,
            inclusion: { in: VALID_SYSTEM_NAMES },
            uniqueness: { scope: :business_id }

  before_validation :ensure_system_sections
  validate :valid_system_name_and_section

  validate :systags_must_be_root

  def to_s
    name
  end

  def title
    name
  end

  # gem descendants seems buggy
  def self_and_descendants
    if children.empty?
      [self]
    else
      [self,children.map(&:self_and_descendants)]
    end.flatten
  end

  def self.system_tags_root(system_name)
    self.where(system_name: system_name)
  end

  def self.system_tags_tree(business_id,system_name)
    Rails.cache.fetch([business_id,system_name,"system_tags_tree"], expires_in: 1.minute) do
      root = Tag.where(system_name: system_name, business_id: business_id)
      root.self_and_descendants
    end
  end

  private

  def systags_must_be_root
    if self.system_name.in?(VALID_SYSTEM_NAMES) && !self.parent_id.nil?
      self.errors.add(:parent_id, "systag must be root")
    end
  end

  def valid_system_name_and_section
    if self.system_name.in?(VALID_SYSTEM_NAMES) && self.admpart_section != "income"
      self.errors.add(:admpart_section, "must be income")
    end
  end

  def ensure_system_sections
    if self.system_name.in?(VALID_SYSTEM_NAMES)
      self.admpart_section = "income"
    end
  end

end
