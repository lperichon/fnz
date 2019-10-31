class CreateBalanceChecks < ActiveRecord::Migration
  def change
    create_table :balance_checks do |t|
      t.integer     :account_id

      t.integer     :creator_id

      t.integer     :balance_cents
      t.datetime    :checked_at

      t.timestamps
    end
    add_index :balance_checks, :account_id
  end
end
