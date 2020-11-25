class EnrollmentTransaction < ActiveRecord::Base
  self.table_name = :enrollments_transactions

  belongs_to :enrollment
  belongs_to :transaction

  #attr_accessible :transaction_id
end
