class InstallmentTransaction < ActiveRecord::Base
  self.table_name = :installments_transactions

  belongs_to :installment
  belongs_to :transaction

  attr_accessible :transaction_id

  after_save :update_installment_balance
  after_destroy :update_installment_balance

  def update_installment_balance
    installment.update_balance
  end
end
