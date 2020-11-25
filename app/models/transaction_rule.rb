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
  def self.select_matching(transaction)
    self.select{|rule| rule.matches?(transaction) }
  end

  def matches?(transaction)
    return nil if transaction.try(:description).blank?

    case operator
    when 'contains'
      transaction.description.downcase.include?(value.downcase)
    when 'regex'
      !!transaction.description.match(value)
    end
  end

  def set_values(transaction)
    if transaction.contact_id.blank? and !contact_id.blank?
      transaction.contact_id = contact_id
    end
    if transaction.agent_id.blank? and !agent_id.blank?
      transaction.agent_id = agent_id
    end
    if transaction.admpart_tag_id.blank? and !admpart_tag_id.blank?
      transaction.admpart_tag_id = admpart_tag_id
      transaction.tag_id = admpart_tag_id
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
