class Tag < ActiveRecord::Base
  acts_as_nested_set
  include TheSortableTree::Scopes

  belongs_to :business

  has_many :taggings, :dependent => :destroy

  validates :name, :presence => true
  validates :business, :presence => true

  default_scope order('name ASC')

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :business_id

  validates_uniqueness_of :name
  validates_length_of :name, :maximum => 255

  def to_s
    name
  end

  def title
    name
  end

end
