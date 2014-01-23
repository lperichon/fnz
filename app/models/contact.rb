class Contact < ActiveRecord::Base
  belongs_to :business

  validates :name, :presence => true
  validates :business, :presence => true

  has_many :memberships
  has_many :installments, :through => :memberships

  scope :students, joins(:memberships).where('memberships.closed_on' => nil).where("padma_status != 'former_student' OR padma_status IS NULL").uniq
  scope :students_without_membership, joins("left outer join memberships on contacts.id = memberships.contact_id").where(:padma_status => 'student').where('memberships.id' => nil)
  scope :former_students_with_open_membership, joins(:memberships).where('memberships.closed_on' => nil).where(:padma_status => 'former_student')

  scope :all_students, joins("left outer join memberships on contacts.id = memberships.contact_id").where("(padma_status = 'former_student' OR padma_status = 'student') OR (padma_status IS NULL AND memberships.id NOT NULL)").uniq 

  default_scope order('name ASC')

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :business_id, :padma_id, :padma_status, :padma_teacher

  def membership
    membership = memberships.where(:business_id => business.id).last
    membership unless membership.try(:closed_on)
  end

  def padma
    PadmaContact.find(padma_id, select: [:email]) if padma_id
  end
  
  # TODO: cache email
  def email
    padma.email
  end

  def installment_for(date)
    installments.where("due_on >= '#{date.beginning_of_month}' AND due_on <= '#{date.end_of_month}'").first
  end
end
