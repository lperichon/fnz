class Membership < ActiveRecord::Base
  belongs_to :business
  belongs_to :contact
  belongs_to :payment_type
  has_many :installments
  has_one :enrollment

  validates :business, :presence => true
  validates :contact, :presence => true
  validates :begins_on, :presence => true
  validates :ends_on, :presence => true
  validates_datetime :ends_on, :after => :begins_on

  # Setup accessible (or protected) attributes for your model
  attr_accessible :contact_id, :business_id, :payment_type_id, :begins_on, :ends_on, :value, :closed_on

  def closed?
    closed_on.present?
  end

  def overdue?
    ends_on < Date.today
  end

  def due?
    (Date.today..Date.today.end_of_month).include? ends_on
  end

  def as_json_for_messaging
    json = as_json
    json["ends_on"] = ends_on
    json["contact_id"] = contact.padma_id
    json["recipient_email"] = contact.email
    json["username"] = contact.padma_teacher
    json["account_name"] = business.padma_id
    json
  end
end
