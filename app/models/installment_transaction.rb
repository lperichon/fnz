class InstallmentTransaction < ActiveRecord::Base
  self.table_name = :installments_transactions

  belongs_to :installment
  belongs_to :trans, foreign_key: 'transaction_id', class_name: "Transaction"#:transaction
  alias_method :transactions, :trans

  #attr_accessible :transaction_id, :installment_id

  validates :transaction_id, uniqueness: { scope: :installment_id }

  after_save :update_installment
  after_destroy :update_installment

  def update_installment
    installment.update_balance_and_status
  end
end
