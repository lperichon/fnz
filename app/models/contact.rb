class Contact < ActiveRecord::Base
  belongs_to :business

  validates :name, :presence => true
  validates :business, :presence => true

  belongs_to :current_membership, :foreign_key => "current_membership_id", :class_name => "Membership"
  has_many :memberships
  has_many :installments, :through => :memberships

  has_many :sales

  scope :students, joins(:memberships).where('memberships.closed_on' => nil).where("padma_status != 'former_student' OR padma_status IS NULL").uniq
  scope :students_without_membership, joins("left outer join memberships on contacts.id = memberships.contact_id").where(:padma_status => 'student').where('memberships.id' => nil)
  scope :former_students_with_open_membership, joins(:memberships).where('memberships.closed_on' => nil).where(:padma_status => 'former_student')

  default_scope order('name ASC')

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :business_id, :padma_id, :padma_status, :padma_teacher

  def self.all_students(membership_filter=nil)
    scope = self.joins("left outer join memberships on contacts.id = memberships.contact_id")
    unless membership_filter.nil?
      membership_filter.delete(:payment_type_id) if membership_filter[:payment_type_id].blank?
      scope = scope.where(memberships: membership_filter) unless membership_filter.empty?
    end
    scope = scope.where("padma_status = 'student' OR ((padma_status IS NULL OR padma_status = 'former_student') AND memberships.id IS NOT NULL AND memberships.closed_on IS NULL AND memberships.ends_on > '#{Date.today}')").includes(:business).includes(:current_membership).includes(:current_membership => :installments).uniq 
  end

  def old_membership
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
