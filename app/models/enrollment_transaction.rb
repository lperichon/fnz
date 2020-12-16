class EnrollmentTransaction < ActiveRecord::Base
  self.table_name = :enrollments_transactions

  belongs_to :enrollment
  belongs_to :tran, class_name: "Transaction", foreign_key: "transaction_id"#:transaction

  #attr_accessible :transaction_id
end
