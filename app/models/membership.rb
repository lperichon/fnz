class Membership < ActiveRecord::Base
  attr_accessor :create_monthly_installments

  belongs_to :business
  belongs_to :contact, :touch => true
  belongs_to :payment_type
  has_many :installments
  has_one :enrollment

  validates :value, :numericality =>  {:greater_than_or_equal => 0}
  validates :business, :presence => true
  validates :contact, :presence => true
  validates :begins_on, :presence => true
  validates :ends_on, :presence => true
  validates_datetime :ends_on, :after => :begins_on
  validates :monthly_due_day, :numericality =>  {:greater_than => 0, :less_than => 29}
  validate  :avoid_overlapping

  # Setup accessible (or protected) attributes for your model
  #attr_accessible :contact_id, :business_id, :payment_type_id, :begins_on, :ends_on, :value, :closed_on, :vip, :external_id, :monthly_due_day, :name, :create_monthly_installments

  after_save :update_contacts_current_membership

  after_save :create_the_monthly_installments, if: :create_monthly_installments

  after_initialize :init

  include BelongsToPadmaContact

  default_scope order('begins_on DESC')

  scope :current, -> { where(:closed_on => nil).select("DISTINCT ON(contact_id) *").order("contact_id, begins_on DESC") }
  scope :wout_installments, -> { joins("left outer join installments on memberships.id = installments.membership_id").where('installments.id' => nil) }
  scope :open, -> { where(closed_on: nil) }
  scope :valid_on, ->(ref_date){ open.where("begins_on <= :rd and ends_on >= :rd", rd: ref_date) }

  def self.wout_installments_due_on_month(ref_date)
    all_ids = self.pluck(:id)
    period = (ref_date.beginning_of_month..ref_date.end_of_month)
    with_installment_ids = self.joins(:installments).where(installments: { due_on: period }).pluck(:id)
    self.where(id: (all_ids - with_installment_ids))
  end

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

    return unless padma_contact

    fnz_contact = Contact.find_or_create_by_padma_id(:padma_id => padma_contact.id,
                                                 :business_id => business.id,
                                                 :name => "#{padma_contact.first_name} #{padma_contact.last_name}".strip,
                                                 :padma_status => padma_contact.status,
                                                 :padma_teacher => padma_contact.global_teacher_username)

    membership.attributes = {
        :business_id => business.id,
        :begins_on => Date.parse(row[2]),
        :ends_on => Date.parse(row[3]),
        :vip => row[5] == 'true',
        :contact_id => fnz_contact.id,
        :external_id => row[0].to_i,
        :monthly_due_day => 10,
        :value => 0 # Kshêma doesnt store plan value
    }

    unless row[8].blank? # if cancelled
      membership.closed_on = Date.parse(row[8]) # Kshêma doesnt store cancellation date
    end

    return membership
  end

  def self.csv_header
    "id,nombre,ini,fin,alumno_id,vip,obs,forma_id,canceled,school_id,person_name,created_at,updated_at".split(',')
  end

  def update_contacts_current_membership
    contact.update_current_membership
  end

  private

  def avoid_overlapping
    return if contact.nil? || begins_on.nil? || ends_on.nil?
    if contact.memberships
              .where("id != ?", id)
              .where("? BETWEEN begins_on AND ends_on", begins_on)
              .exists?
      errors.add(:begins_on, _("Se superpone con otra membersia de este contacto"))
    end
    if contact.memberships
              .where("id != ?", id)
              .where("? BETWEEN begins_on AND ends_on", ends_on)
              .exists?
      errors.add(:ends_on, _("Se superpone con otra membersia de este contacto"))
    end
  end

  def create_the_monthly_installments
    i = 0
    begin
      installment_date = Date.civil(begins_on.year,begins_on.month,monthly_due_day) + i.months

      if installment_date >= begins_on.to_date && installment_date <= ends_on.to_date
        self.installments.create(value: value, due_on: installment_date)
      end

      i += 1
    end until installment_date > ends_on.to_date
  end

  def init
    if self.new_record? && self.monthly_due_day.nil?
      self.monthly_due_day = 10
    end
  end

end
