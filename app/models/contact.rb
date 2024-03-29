# ATENTION - padma_id is not unique
#                     this model represents padma's account-contact realation
class Contact < ActiveRecord::Base
  include GetsByPadmaId

  belongs_to :business

  validates :name, :presence => true
  validates :business, :presence => true

  belongs_to :current_membership, :foreign_key => "current_membership_id", :class_name => "Membership"
  has_many :memberships
  has_many :installments, :through => :memberships

  has_many :sales

  scope :students, -> { joins(:memberships).where('memberships.closed_on' => nil).where("padma_status != 'former_student' OR padma_status IS NULL").uniq }
  scope :students_without_membership, -> { joins("left outer join memberships on contacts.id = memberships.contact_id").where(:padma_status => 'student').where('memberships.id' => nil) }
  scope :former_students_with_open_membership, -> { joins(:memberships).where('memberships.closed_on' => nil).where(:padma_status => 'former_student') }

  default_scope { order('contacts.name ASC') }

  # Setup accessible (or protected) attributes for your model
  #attr_accessible :name, :business_id, :padma_id, :padma_status, :padma_teacher



  def self.all_students
    scope = self.joins("left outer join memberships on contacts.id = memberships.contact_id")
    scope = scope.includes(:business).includes(:current_membership).uniq
  end

  def old_membership
    membership = memberships.where(:business_id => business.id).last
    membership unless membership.try(:closed_on)
  end

  # @return [Agent]
  def teacher
    unless @teacher
      if padma_teacher
        @teacher = business.agents.find_by_padma_id padma_teacher
      end
    end
    @teacher
  end

  def installment_for(date)
    installments.where("due_on >= '#{date.beginning_of_month}' AND due_on <= '#{date.end_of_month}'").first
  end

  def update_current_membership

    # fetching timezone from business would call accounts-ws
    # set time zone outside
    update_attribute(:current_membership_id, memberships.where(closed_on: nil).valid_on(Time.zone.today).first.try(:id))
  end

  private

  def self.get_business_from_scope(scope)
    Business.get_from_scope(scope)
  end
end
