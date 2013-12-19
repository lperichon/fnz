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
  attr_accessible :contact_id, :business_id, :payment_type_id, :begins_on, :ends_on, :value, :closed_on, :vip

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

  def self.build_from_csv(business, row)
    membership = Membership.new

    padma_contact = PadmaContact.find_by_kshema_id(row[4])
    puts padma_contact.id
    fnz_contact = Contact.find_or_create_by_padma_id(:padma_id => padma_contact.id,
                                                 :business_id => business.id,
                                                 :name => "#{padma_contact.first_name} #{padma_contact.last_name}".strip,
                                                 :padma_status => padma_contact.status,
                                                 :padma_teacher => padma_contact.global_teacher_username)
    puts fnz_contact.errors.full_messages
    membership.attributes = {
        :business_id => business.id,
        :begins_on => Date.parse(row[2]),
        :ends_on => Date.parse(row[3]),
        :vip => row[4] == 'true',
        :contact_id => fnz_contact.id
    }

    if row[8] == 'true' # if cancelled
      membership.closed_on = membership.ends_on # Kshêma doesnt store cancellation date
    end

    membership.valid?

    puts membership.errors.full_messages

    return membership
  end

  def self.csv_header
    "id,nombre,ini,fin,alumno_id,vip,obs,forma_id,canceled,school_id,person_name,created_at,updated_at".split(',')
  end
end
