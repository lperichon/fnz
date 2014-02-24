class AddTransactionsFeatureFlagToBusinesses < ActiveRecord::Migration
  def change
  	add_column :businesses, :transactions_enabled, :boolean
  end
end
