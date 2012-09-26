class InstallmentTransaction < ActiveRecord::Base
  set_table_name :installments_transactions

  belongs_to :installment
  belongs_to :transaction

  attr_accessible :transaction_id
end
