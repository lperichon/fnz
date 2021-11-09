class Tag < ActiveRecord::Base
  acts_as_nested_set scope: :business_id # TODO esto del scope parece no funcionar
  include TheSortableTree::Scopes

  belongs_to :business

  has_many :taggings, :dependent => :destroy
  has_many :trans, foreign_key: 'transaction_id', class_name: "Transaction", through: :taggings

  has_many :month_tag_totals, dependent: :destroy
  after_update :update_all_month_totals

  validates :name, :presence => true
  validates :business, :presence => true

  default_scope { order('tags.name ASC') }

  # Setup accessible (or protected) attributes for your model
  #attr_accessible :name, :business_id, :admpart_section, :system_name

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

  before_destroy :cancel_if_system_tag

  def to_s
    name
  end

  def title
    name
  end

  # 
  # descendants seems to be working ok on newer versions of gem
  # when using this override I have to override a los of methods because an Array
  # is passed instead of an active record relation
  #
  # gem descendants seems buggy
  # def self_and_descendants
  #   if children.empty?
  #     [self]
  #   else
  #     [self,children.map(&:self_and_descendants)]
  #   end.flatten
  # end

  # override gem descendants method as it throws an error with the above override
  # def descendants
  #   without_self self_and_descendants
  # end

  # override gem without selg method as it throws an error with the override above
  # def without_self(sc)
  #   return sc if new_record?
  #   if sc.class == Array
  #     sc - [self]
  #   else
  #     sc.where(["#{self.class.quoted_table_name}.#{self.class.quoted_primary_column_name} != ?", self.primary_id])
  #   end
  # end

  # tagged by this tag and its descendants
  def tree_transactions
    Transaction.where(admpart_tag_id: self_and_descendants.map(&:id))
  end

  def month_total(ref_date)

    MonthTagTotal.get_for(self,ref_date).total_amount
  end

  def self.system_tags_root(system_name)
    self.where(system_name: system_name)
  end

  def self.system_tags_tree(business_id,system_name)
    root = Tag.where(system_name: system_name, business_id: business_id).first
    if root
      root.self_and_descendants
    end
  end

  def self.get_system_tag(sysname)
    t = self.where(system_name: sysname).first
    if t.nil?
      t = self.create!(
        name: I18n.t("tag.system_names.#{sysname}"),
        admpart_section: "income",
        system_name: sysname
      )
    end
    t
  end

  VALID_SYSTEM_NAMES.each do |sysname|
    define_singleton_method "get_#{sysname}s_tag" do
      self.get_system_tag(sysname)
    end
  end

  def is_system_tag?
    system_name.in?(VALID_SYSTEM_NAMES)
  end

  def update_all_month_totals
    if parent_id_changed?
      Tag.find(parent_id_was).update_all_month_totals
    end
    if parent
      parent.update_all_month_totals
    end
    month_tag_totals.each &:refresh
  end

  def update_month_total(ref_date)
    if parent
      parent.update_month_total(ref_date)
    end
    MonthTagTotal.get_for(self,ref_date).refresh # updates or creates
  end

  private

  def cancel_if_system_tag
    unless system_name.blank?
      return false # this cancels callbacks and destroy
    end
  end

  def systags_must_be_root
    if is_system_tag? && !self.parent_id.nil?
      self.errors.add(:parent_id, _("etiqueta de sistema tiene que ser raiz, no puede estar bajo otra"))
    end
  end

  def valid_system_name_and_section
    if is_system_tag? && self.admpart_section != "income"
      self.errors.add(:admpart_section, _("tiene que estar en 'income'"))
    end
  end

  def ensure_system_sections
    if is_system_tag?
      self.admpart_section = "income"
    end
  end

end
