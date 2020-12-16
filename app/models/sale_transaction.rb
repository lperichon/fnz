class SaleTransaction < ActiveRecord::Base
  self.table_name = :sales_transactions

  belongs_to :sale
  belongs_to :tran, class_name: "Transaction", foreign_key: "transaction_id"#:transaction

  #attr_accessible :transaction_id
end
