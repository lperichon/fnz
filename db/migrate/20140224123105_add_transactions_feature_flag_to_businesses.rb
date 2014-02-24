class AddTransactionsFeatureFlagToBusinesses < ActiveRecord::Migration
  def change
  	add_column :businesses, :transactions_enabled, :boolean
  	add_column :businesses, :share_enabled, :boolean
  end
end
