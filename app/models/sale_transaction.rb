class SaleTransaction < ActiveRecord::Base
  self.table_name = :sales_transactions

  belongs_to :sale
  belongs_to :trans, foreign_key: 'transaction_id', class_name: "Transaction"#:transaction
  alias_method :transactions, :trans

  #attr_accessible :transaction_id
end
