class AddIndexesForOverview < ActiveRecord::Migration
  def change
    add_index :contacts, :business_id
    add_index :contacts, :current_membership_id

    add_index :memberships, :business_id
    add_index :memberships, :contact_id
    add_index :memberships, :payment_type_id
    add_index :memberships, [:business_id, :payment_type_id]

    add_index :installments, :membership_id

    add_index :installments_transactions, [:installment_id, :transaction_id], name: :installment_transaction_link_index

    add_index :transactions, :business_id
  end
end
