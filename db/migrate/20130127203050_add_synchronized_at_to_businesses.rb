class AddSynchronizedAtToBusinesses < ActiveRecord::Migration
  def change
    add_column :businesses, :synchronized_at, :datetime
  end
end
