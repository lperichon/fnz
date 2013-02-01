class Contact < ActiveRecord::Base
  belongs_to :business

  validates :name, :presence => true
  validates :business, :presence => true

  has_many :memberships

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :business_id, :padma_id, :padma_status

  def membership
    membership = memberships.first
    membership unless membership.try(:closed_on)
  end

  def padma
    PadmaContact.find(padma_id) if padma_id
  end

  def email
    padma.emails.find(:primary => true)
  end

  def status
    padma_status.present? ? padma_status : padma.status
  end
end
