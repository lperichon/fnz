class InstallmentTransaction < ActiveRecord::Base
  self.table_name = :installments_transactions

  belongs_to :installment
  belongs_to :transaction

  attr_accessible :transaction_id

  after_save :update_installment
  after_destroy :update_installment

  def update_installment
    installment.update_balance
    installment.update_status
  end
end
