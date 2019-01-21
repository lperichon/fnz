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
      transaction.update_attributes(
        contact_id: installment.try(:membership).try(:contact_id),
        agent_id: installment.agent_id
      )
    end
  end
end
