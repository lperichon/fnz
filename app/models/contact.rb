class Contact < ActiveRecord::Base
  belongs_to :business

  validates :name, :presence => true
  validates :business, :presence => true

  has_many :memberships
  has_many :installments, :through => :memberships

  scope :students, where(:padma_status => 'student')

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :business_id, :padma_id, :padma_status, :padma_teacher

  def membership
    membership = memberships.last
    membership unless membership.try(:closed_on)
  end

  def padma
    PadmaContact.find(padma_id) if padma_id
  end

  def email
    padma.emails.find(:primary => true)
  end

  def installment_for(date)
    installments.where("due_on >= '#{date.beginning_of_month}' AND due_on <= '#{date.end_of_month}'").first
  end
end
