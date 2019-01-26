# ATENTION - padma_id is not unique
#                     this model represents padma's account-contact realation
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

  default_scope order('contacts.name ASC')

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :business_id, :padma_id, :padma_status, :padma_teacher

  # finds contact by padma_id
  # if it doesnt exist it creates
  # BUSINESS should be specified on scope, padma_id is not unique
  def self.get_by_padma_id(padma_id)
    c = self.find_by_padma_id(padma_id)
    if c.nil?
      business_id = get_bussines_from_scope(self)
      if business_id
        b = Business.find(business_id)
        padma_contact = PadmaContact.find(padma_id,
                          select: [:id, :full_name, :local_status, :local_teacher],
                          account_name: b.padma_id
                         ) 
        if padma_contact
          c = b.contacts.create(
            :name => "#{padma_contact.first_name} #{padma_contact.last_name}".strip,
            :padma_status => padma_contact.local_status,
            :padma_teacher => padma_contact.local_teacher,
            :padma_id => padma_contact.id)
        end
      end
    end
    c
  end

  def self.all_students
    scope = self.joins("left outer join memberships on contacts.id = memberships.contact_id")
    scope = scope.includes(:business).includes(:current_membership).uniq 
  end

  def old_membership
    membership = memberships.where(:business_id => business.id).last
    membership unless membership.try(:closed_on)
  end

  def teacher
    if padma_teacher
      Rails.cache.fetch([business_id, "agent_by_username", padma_teacher], expires_in: 5.minutes) do
        business.agents.find_by_padma_id padma_teacher
      end
    end
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

  private
  
  def self.get_bussines_from_scope(scope)
    scope = scope.scoped
    res = scope.to_sql.match(/business_id\" \= (\d+)/)
    (res)? res[1].to_i : nil
  end
end
