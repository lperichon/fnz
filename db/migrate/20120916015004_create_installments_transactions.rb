class CreateInstallmentsTransactions < ActiveRecord::Migration
  def change
    create_table :installments_transactions, :id => false do |t|
      t.references :installment
      t.references :transaction
    end
  end
end
