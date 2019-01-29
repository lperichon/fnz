class IndexEnrollments < ActiveRecord::Migration
  def change
    add_index :enrollments, :membership_id
    add_index :enrollments, :agent_id
    add_index :enrollments_transactions, [:enrollment_id, :transaction_id], name: "enrollments_transactions_link_index"
  end
end
