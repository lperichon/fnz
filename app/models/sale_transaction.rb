class SaleTransaction < ActiveRecord::Base
  set_table_name :sales_transactions

  belongs_to :sale
  belongs_to :transaction

  attr_accessible :transaction_id
end
