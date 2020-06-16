class TransactionRule < ActiveRecord::Base

  VALID_OPERATORS = %W(contains regex)
  validates :operator, inclusion: { in: VALID_OPERATORS }
  validates :value, presence: true, allow_blank: false

  belongs_to :business
  validates :business, presence: true

  belongs_to :contact
  belongs_to :agent
  belongs_to :admpart_tag, class_name: "Tag"


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
    transaction.contact_id = contact_id unless contact_id.blank?
    transaction.agent_id = agent_id unless agent_id.blank?
    transaction.admpart_tag_id = admpart_tag_id unless admpart_tag_id.blank?
  end

end
