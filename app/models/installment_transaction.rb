class InstallmentTransaction < ActiveRecord::Base
  self.table_name = :installments_transactions

  belongs_to :installment
  belongs_to :transaction

  attr_accessible :transaction_id

  after_save :update_installment
  after_destroy :update_installment

  after_save :set_transaction_contact_and_agent

  def update_installment
    installment.update_balance_and_status
  end

  def set_transaction_contact_and_agent
    if installment
      attrs = {
        contact_id: installment.try(:membership).try(:contact_id),
        agent_id: installment.agent_id
      }
      if t = Tag.where(business_id: transaction.business_id, system_name: "installment").first
        attrs.merge( tag_id: t.id )
      end
      transaction.update_attributes( attrs )
    end
  end
end
