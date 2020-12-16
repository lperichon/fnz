class TransactionRule < ActiveRecord::Base
  #attr_accessible :admpart_tag_id,
  #                :agent_id,
  #                :contact_id,
  #                :operator,
  #                :value


  VALID_OPERATORS = %W(contains regex)
  validates :operator, inclusion: { in: VALID_OPERATORS }
  validates :value, presence: true, allow_blank: false

  belongs_to :business
  validates :business, presence: true

  belongs_to :contact
  belongs_to :agent
  belongs_to :admpart_tag, class_name: "Tag"

  validate :at_least_one_assignment


  # @return Array [TransactionRule]
  def self.select_matching(tran)
    self.select{|rule| rule.matches?(tran) }
  end

  def matches?(tran)
    return nil if tran.try(:description).blank?

    case operator
    when 'contains'
      tran.description.downcase.include?(value.downcase)
    when 'regex'
      !!tran.description.match(value)
    end
  end

  def set_values(tran)
    if tran.contact_id.blank? and !contact_id.blank?
      tran.contact_id = contact_id
    end
    if tran.agent_id.blank? and !agent_id.blank?
      tran.agent_id = agent_id
    end
    if tran.admpart_tag_id.blank? and !admpart_tag_id.blank?
      tran.admpart_tag_id = admpart_tag_id
      tran.tag_id = admpart_tag_id
    end
  end

  private

  def at_least_one_assignment
    if agent_id.blank? && contact_id.blank? && admpart_tag_id.blank?
      errors.add(:agent_id, _("Elija por lo menos un valor a asignar"))
      errors.add(:contact_id, _("Elija por lo menos un valor a asignar"))
      errors.add(:admpart_tag_id, _("Elija por lo menos un valor a asignar"))
    end
  end

end
